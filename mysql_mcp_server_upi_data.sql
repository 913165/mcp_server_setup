
-- ABC Bank UPI failure demo | MySQL 8.0.16+
-- Seed timestamps are relative to NOW(), so re-run right before the demo.

CREATE DATABASE IF NOT EXISTS abcbank_upi CHARACTER SET utf8mb4;
USE abcbank_upi;

DROP VIEW  IF EXISTS v_error_clusters;
DROP VIEW  IF EXISTS v_incidents;
DROP TABLE IF EXISTS incidents;
DROP TABLE IF EXISTS upi_error_logs;

-- ---------------------------------------------------------------
-- 1. Logs
-- ---------------------------------------------------------------
CREATE TABLE upi_error_logs (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  log_ts      DATETIME(3)  NOT NULL,
  level       ENUM('INFO','WARN','ERROR') NOT NULL,
  component   VARCHAR(40)  NOT NULL,            -- upi-switch | npci-gateway
  txn_id      VARCHAR(40)  NULL,
  rrn         VARCHAR(12)  NULL,
  stage       VARCHAR(30)  NOT NULL,            -- CBS_DEBIT | NPCI_FORWARD | ...
  resp_code   VARCHAR(5)   NOT NULL,            -- 51, 91, U30 ...
  reason      VARCHAR(255) NOT NULL,
  reason_norm VARCHAR(255) NOT NULL,            -- reason with numbers replaced by #
  payer_vpa   VARCHAR(60)  NULL,                -- masked
  payee_vpa   VARCHAR(60)  NULL,                -- masked
  amount      DECIMAL(12,2) NULL,
  extra_json  JSON NULL,
  error_signature VARCHAR(255)
    GENERATED ALWAYS AS (CONCAT(component,'|',stage,'|',resp_code,'|',reason_norm)) STORED,
  KEY idx_ts (log_ts),
  KEY idx_sig (error_signature),
  KEY idx_rrn (rrn)
);

-- ---------------------------------------------------------------
-- 2. Incidents (id starts at 10001; use v_incidents for INC-xxxxx)
-- ---------------------------------------------------------------
CREATE TABLE incidents (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  title           VARCHAR(200) NOT NULL,
  category        ENUM('TECHNICAL_CBS','INFRA_NPCI','ISSUER_DECLINE',
                       'BENEFICIARY_DECLINE','CUSTOMER_DECLINE','OTHER') NOT NULL,
  severity        ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL,
  status          ENUM('OPEN','IN_PROGRESS','RESOLVED') NOT NULL DEFAULT 'OPEN',
  error_signature VARCHAR(255) NOT NULL,
  affected_count  INT NOT NULL,
  sample_rrns     JSON NULL,
  first_seen      DATETIME(3) NULL,
  last_seen       DATETIME(3) NULL,
  probable_cause  VARCHAR(500) NULL,
  runbook_ref     VARCHAR(100) NULL,
  created_by      VARCHAR(50) NOT NULL DEFAULT 'upi-ops-agent',
  created_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  -- hard dedup: only one OPEN/IN_PROGRESS incident per signature (NULLs are ignored by unique index)
  active_signature VARCHAR(255)
    GENERATED ALWAYS AS (IF(status IN ('OPEN','IN_PROGRESS'), error_signature, NULL)) STORED,
  UNIQUE KEY uq_active_sig (active_signature)
) AUTO_INCREMENT = 10001;

-- ---------------------------------------------------------------
-- 3. Views for the LLM (simple SELECTs, no hand-written GROUP BY)
-- ---------------------------------------------------------------
CREATE VIEW v_incidents AS
SELECT CONCAT('INC-', LPAD(id,5,'0')) AS incident_no, id, title, category, severity, status,
       error_signature, affected_count, sample_rrns, first_seen, last_seen,
       probable_cause, runbook_ref, created_by, created_at
FROM incidents;

-- Clusters of the last 60 minutes. Filter further with WHERE last_seen >= NOW() - INTERVAL n MINUTE
CREATE VIEW v_error_clusters AS
SELECT error_signature, component, stage, resp_code, reason_norm,
       MAX(reason)  AS sample_reason,
       MAX(level)   AS max_level,
       COUNT(*)     AS cnt,
       MIN(log_ts)  AS first_seen,
       MAX(log_ts)  AS last_seen,
       SUBSTRING_INDEX(GROUP_CONCAT(rrn ORDER BY log_ts DESC SEPARATOR ','), ',', 5) AS sample_rrns
FROM upi_error_logs
WHERE log_ts >= NOW() - INTERVAL 60 MINUTE
GROUP BY error_signature, component, stage, resp_code, reason_norm;

-- ---------------------------------------------------------------
-- 4. Seed: the three hand-written logs from earlier (last ~5 minutes)
-- ---------------------------------------------------------------
INSERT INTO upi_error_logs
(log_ts, level, component, txn_id, rrn, stage, resp_code, reason, reason_norm, payer_vpa, payee_vpa, amount, extra_json) VALUES
-- Log 1: CBS timeout
(NOW(3) - INTERVAL 4 MINUTE, 'ERROR','upi-switch','UPI20261005104217A91F','627810421733','CBS_DEBIT','91',
 'CBS response timeout after 30000ms','CBS response timeout after #ms','ra****@abcbank','sh****@okhdfc',2500.00,
 JSON_OBJECT('cbsHost','cbs-prod-02','retryCount',0,'status','DEEMED')),
-- Log 2: Insufficient funds
(NOW(3) - INTERVAL 3 MINUTE, 'INFO','upi-switch','UPI20261005104302C4D2','627810430212','CBS_DEBIT','51',
 'Insufficient funds','Insufficient funds','mk****@abcbank','bigbazaar@icici',18400.00,
 JSON_OBJECT('availBal',3120.55,'acctType','SAVINGS')),
-- Log 3: NPCI read timeout, pool exhausted, pool acquire failures
(NOW(3) - INTERVAL 2 MINUTE, 'ERROR','npci-gateway','UPI20261005104544E7B3','627810454401','NPCI_FORWARD','U30',
 'java.net.SocketTimeoutException: Read timed out','java.net.SocketTimeoutException: Read timed out',NULL,NULL,NULL,
 JSON_OBJECT('npciEndpoint','upi-npci-prod-mum','latencyMs',60012)),
(NOW(3) - INTERVAL 2 MINUTE, 'ERROR','npci-gateway',NULL,NULL,'NPCI_FORWARD','U30',
 'Connection pool exhausted active=200/200 waiting=143','Connection pool exhausted active=#/# waiting=#',NULL,NULL,NULL,
 JSON_OBJECT('pool','npci-conn-pool')),
(NOW(3) - INTERVAL 110 SECOND, 'ERROR','npci-gateway','UPI20261005104545F1A8','627810454502','NPCI_FORWARD','U30',
 'Unable to acquire connection from pool within 5000ms','Unable to acquire connection from pool within #ms',NULL,NULL,NULL,NULL),
(NOW(3) - INTERVAL 108 SECOND, 'ERROR','npci-gateway','UPI20261005104545B2C9','627810454503','NPCI_FORWARD','U30',
 'Unable to acquire connection from pool within 5000ms','Unable to acquire connection from pool within #ms',NULL,NULL,NULL,NULL);

-- ---------------------------------------------------------------
-- 5. Seed: bulk volume (~300 rows) via recursive CTE
-- ---------------------------------------------------------------

-- 5a. Insufficient funds: 180 rows spread over last 60 min (noise, should NOT become incidents)
INSERT INTO upi_error_logs
(log_ts, level, component, txn_id, rrn, stage, resp_code, reason, reason_norm, payer_vpa, payee_vpa, amount, extra_json)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i+1 FROM n WHERE i < 180)
SELECT ts, 'INFO','upi-switch',
       CONCAT('UPI',DATE_FORMAT(ts,'%Y%m%d%H%i%s'),UPPER(SUBSTRING(MD5(RAND()),1,4))),
       CONCAT('6278',LPAD(FLOOR(RAND()*100000000),8,'0')),
       'CBS_DEBIT','51','Insufficient funds','Insufficient funds',
       CONCAT(ELT(1+FLOOR(RAND()*5),'ra','mk','sn','pk','dv'),'****@abcbank'),
       ELT(1+FLOOR(RAND()*5),'swiggy@icici','amazon@apl','sh****@okhdfc','zomato@hdfcbank','pt****@ybl'),
       ROUND(100+RAND()*20000,2),
       JSON_OBJECT('acctType',ELT(1+FLOOR(RAND()*2),'SAVINGS','CURRENT'))
FROM (SELECT i, NOW(3) - INTERVAL FLOOR(RAND()*3600000)*1000 MICROSECOND AS ts FROM n) t;

-- 5b. CBS timeout: 50 rows in a burst 20-30 min ago, 25 rows spread out
INSERT INTO upi_error_logs
(log_ts, level, component, txn_id, rrn, stage, resp_code, reason, reason_norm, payer_vpa, payee_vpa, amount, extra_json)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i+1 FROM n WHERE i < 75)
SELECT ts, 'ERROR','upi-switch',
       CONCAT('UPI',DATE_FORMAT(ts,'%Y%m%d%H%i%s'),UPPER(SUBSTRING(MD5(RAND()),1,4))),
       CONCAT('6278',LPAD(FLOOR(RAND()*100000000),8,'0')),
       'CBS_DEBIT','91','CBS response timeout after 30000ms','CBS response timeout after #ms',
       CONCAT(ELT(1+FLOOR(RAND()*5),'ra','mk','sn','pk','dv'),'****@abcbank'),
       ELT(1+FLOOR(RAND()*4),'sh****@okhdfc','pt****@ybl','amazon@apl','zomato@hdfcbank'),
       ROUND(100+RAND()*20000,2),
       JSON_OBJECT('cbsHost','cbs-prod-02','retryCount',0,'status','DEEMED')
FROM (
  SELECT i,
    IF(i <= 50,
       NOW(3) - INTERVAL (20*60000 + FLOOR(RAND()*10*60000))*1000 MICROSECOND,
       NOW(3) - INTERVAL FLOOR(RAND()*3600000)*1000 MICROSECOND) AS ts
  FROM n) t;

-- 5c. NPCI gateway failures: 45 rows clustered 5-10 min ago
INSERT INTO upi_error_logs
(log_ts, level, component, txn_id, rrn, stage, resp_code, reason, reason_norm, payer_vpa, payee_vpa, amount, extra_json)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i+1 FROM n WHERE i < 45)
SELECT ts, 'ERROR','npci-gateway',
       IF(i <= 40, CONCAT('UPI',DATE_FORMAT(ts,'%Y%m%d%H%i%s'),UPPER(SUBSTRING(MD5(RAND()),1,4))), NULL),
       IF(i <= 40, CONCAT('6278',LPAD(FLOOR(RAND()*100000000),8,'0')), NULL),
       'NPCI_FORWARD','U30',
       CASE WHEN i <= 15 THEN 'java.net.SocketTimeoutException: Read timed out'
            WHEN i <= 40 THEN 'Unable to acquire connection from pool within 5000ms'
            ELSE 'Connection pool exhausted active=200/200 waiting=143' END,
       CASE WHEN i <= 15 THEN 'java.net.SocketTimeoutException: Read timed out'
            WHEN i <= 40 THEN 'Unable to acquire connection from pool within #ms'
            ELSE 'Connection pool exhausted active=#/# waiting=#' END,
       NULL, NULL, NULL,
       JSON_OBJECT('npciEndpoint','upi-npci-prod-mum')
FROM (SELECT i, NOW(3) - INTERVAL (5*60000 + FLOOR(RAND()*5*60000))*1000 MICROSECOND AS ts FROM n) t;

-- ---------------------------------------------------------------
-- 6. Pre-existing OPEN incident for the CBS timeout signature (tests dedup)
-- ---------------------------------------------------------------
INSERT INTO incidents
(title, category, severity, status, error_signature, affected_count, sample_rrns,
 first_seen, last_seen, probable_cause, runbook_ref, created_by, created_at)
VALUES
('UPI debit failures: CBS response timeouts on cbs-prod-02', 'TECHNICAL_CBS', 'HIGH', 'OPEN',
 'upi-switch|CBS_DEBIT|91|CBS response timeout after #ms', 12,
 JSON_ARRAY('627810421733','627810421801','627810422054'),
 NOW(3) - INTERVAL 35 MINUTE, NOW(3) - INTERVAL 28 MINUTE,
 'CBS host cbs-prod-02 slow responding; possible DB lock or batch job overlap',
 'RB-CBS-017', 'ops.user', NOW(3) - INTERVAL 27 MINUTE);

-- ---------------------------------------------------------------
-- 7. Least-privilege user for the MySQL MCP server
-- ---------------------------------------------------------------
-- CREATE USER 'mcp_agent'@'%' IDENTIFIED BY 'change_me';
-- GRANT SELECT ON abcbank_upi.upi_error_logs   TO 'mcp_agent'@'%';
-- GRANT SELECT ON abcbank_upi.v_error_clusters TO 'mcp_agent'@'%';
-- GRANT SELECT ON abcbank_upi.v_incidents      TO 'mcp_agent'@'%';
-- GRANT SELECT, INSERT ON abcbank_upi.incidents TO 'mcp_agent'@'%';

-- Sanity checks
-- SELECT * FROM v_error_clusters ORDER BY cnt DESC;
-- SELECT * FROM v_incidents;
