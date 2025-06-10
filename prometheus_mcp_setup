# Prometheus MCP Server Setup with Spring Boot

This guide walks through setting up a Prometheus MCP (Model Context Protocol) server with a Spring Boot application for monitoring and metrics collection.

## Prerequisites

- Java 17 or higher
- Docker Desktop (for MCP server)
- Claude Desktop application

## Step 1: Create Spring Boot Project

Create a new Spring Boot project with the following Maven dependencies:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
    <scope>runtime</scope>
</dependency>
```

## Step 2: Configure Application Properties

Add the following configuration to your `application.yml` file:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: '*'
```

This exposes all actuator endpoints, including the Prometheus metrics endpoint.

## Step 3: Verify Spring Boot Metrics

Start your Spring Boot application and verify the following endpoints are accessible:

- **All Actuator Endpoints**: http://localhost:8080/actuator
- **Prometheus Metrics**: http://localhost:8080/actuator/prometheus

The Prometheus endpoint should return metrics in Prometheus format.

## Step 4: Install Prometheus

1. Download Prometheus for Windows from: https://prometheus.io/download/
2. Extract the downloaded archive to a directory of your choice
3. Navigate to the Prometheus directory

## Step 5: Configure Prometheus

Update the `prometheus.yml` configuration file with the following scrape configuration:

```yaml
scrape_configs:
  - job_name: 'spring-boot-application'
    metrics_path: '/actuator/prometheus'
    scrape_interval: 15s # Adjust based on your needs
    static_configs:
      - targets: ['localhost:8080']
```

## Step 6: Start Prometheus

Run Prometheus using the command:
```bash
./prometheus.exe --config.file=prometheus.yml
```

Verify Prometheus is running by accessing: http://localhost:9090/query

## Step 7: Configure Claude Desktop MCP Server

Add the following configuration to your `claude_desktop_config.json` file:

```json
{
  "mcpServers": {
    "prometheus": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "PROMETHEUS_URL",
        "-e", "PROMETHEUS_USERNAME",
        "-e", "PROMETHEUS_PASSWORD",
        "ghcr.io/pab1it0/prometheus-mcp-server:latest"
      ],
      "env": {
        "PROMETHEUS_URL": "http://host.docker.internal:9090",
        "PROMETHEUS_USERNAME": "",
        "PROMETHEUS_PASSWORD": ""
      }
    }
  }
}
```

**Note**: The `host.docker.internal` hostname allows the Docker container to access services running on the host machine.

## Step 8: Restart Claude Desktop

After updating the configuration file, restart Claude Desktop to load the new MCP server configuration.

## Verification

1. **Spring Boot**: Ensure your application is running on port 8080
2. **Prometheus**: Verify it's scraping metrics from your Spring Boot app at http://localhost:9090/targets
3. **Claude Desktop**: Check that the Prometheus MCP server is loaded and can query your metrics

## Troubleshooting

- Ensure Docker Desktop is running before starting Claude Desktop
- Verify that ports 8080 (Spring Boot) and 9090 (Prometheus) are not blocked by firewall
- Check Docker logs if the MCP server fails to start
- Ensure your Spring Boot application is generating metrics by accessing some endpoints first

## Usage

Once configured, you can use Claude Desktop to query Prometheus metrics directly through the MCP server, enabling advanced monitoring and analysis of your Spring Boot application's performance and health metrics.
