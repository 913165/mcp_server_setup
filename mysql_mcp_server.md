Below is a **complete `.md` file content** you can save as:

```
mysql_mcp_setup.md
```

It includes:

* MySQL installation steps
* Root password setup
* Database creation
* Sample tables (4 tables)
* 10+ rows per table
* MCP config
* Test queries

---

# 📘 MySQL + MCP Server Complete Setup Guide

---

# 1️⃣ Install MySQL (Ubuntu / WSL)

```bash
sudo apt update
sudo apt install mysql-server -y
```

Start MySQL:

```bash
sudo service mysql start
```

Login:

```bash
sudo mysql
```

---

# 2️⃣ Set root password

```sql
ALTER USER 'root'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'root123';

FLUSH PRIVILEGES;
```

Test login:

```bash
mysql -u root -p
```

enter password:

```
root123
```

---

# 3️⃣ Create Database

```sql
CREATE DATABASE demo_company;

USE demo_company;
```

---

# 4️⃣ Create Tables

## Department table

```sql
CREATE TABLE department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);
```

---

## Employee table

```sql
CREATE TABLE employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50),
    email VARCHAR(100),
    salary DECIMAL(10,2),
    dept_id INT,
    FOREIGN KEY (dept_id)
    REFERENCES department(dept_id)
);
```

---

## Project table

```sql
CREATE TABLE project (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100),
    budget DECIMAL(12,2)
);
```

---

## Employee_Project table

```sql
CREATE TABLE employee_project (
    id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    project_id INT,
    role VARCHAR(50),

    FOREIGN KEY (emp_id)
    REFERENCES employee(emp_id),

    FOREIGN KEY (project_id)
    REFERENCES project(project_id)
);
```

---

# 5️⃣ Insert Sample Data (10+ rows each)

## Department data

```sql
INSERT INTO department (dept_name, location) VALUES
('Engineering', 'Mumbai'),
('HR', 'Pune'),
('Finance', 'Bangalore'),
('Marketing', 'Delhi'),
('Sales', 'Hyderabad'),
('Support', 'Chennai'),
('Research', 'Ahmedabad'),
('Operations', 'Kolkata'),
('Admin', 'Noida'),
('Training', 'Jaipur');
```

---

## Employee data

```sql
INSERT INTO employee (emp_name, email, salary, dept_id) VALUES
('Rahul Sharma','rahul@gmail.com',75000,1),
('Priya Patel','priya@gmail.com',68000,2),
('Amit Singh','amit@gmail.com',82000,1),
('Neha Verma','neha@gmail.com',72000,3),
('Karan Mehta','karan@gmail.com',91000,4),
('Sneha Iyer','sneha@gmail.com',67000,5),
('Arjun Nair','arjun@gmail.com',88000,6),
('Pooja Shah','pooja@gmail.com',65000,7),
('Vikram Rao','vikram@gmail.com',93000,8),
('Anjali Das','anjali@gmail.com',71000,9),
('Rohit Jain','rohit@gmail.com',76000,10);
```

---

## Project data

```sql
INSERT INTO project (project_name, budget) VALUES
('AI Chatbot',500000),
('Banking App',800000),
('Ecommerce Platform',1200000),
('CRM System',450000),
('HR Portal',300000),
('Inventory Tool',350000),
('Analytics Dashboard',600000),
('Mobile App',700000),
('Automation Tool',400000),
('Cloud Migration',950000);
```

---

## Employee_Project data

```sql
INSERT INTO employee_project (emp_id, project_id, role) VALUES
(1,1,'Developer'),
(2,5,'HR Analyst'),
(3,2,'Tech Lead'),
(4,4,'Finance Analyst'),
(5,3,'Manager'),
(6,6,'Coordinator'),
(7,8,'Tester'),
(8,7,'Researcher'),
(9,9,'Operations Lead'),
(10,10,'Admin Support'),
(11,1,'Developer');
```

---

# 6️⃣ Test Queries

```sql
SELECT * FROM department;

SELECT * FROM employee;

SELECT * FROM project;
```

---

## Join example

```sql
SELECT e.emp_name,
       d.dept_name
FROM employee e
JOIN department d
ON e.dept_id = d.dept_id;
```

---

## Employee Projects

```sql
SELECT e.emp_name,
       p.project_name,
       ep.role
FROM employee e
JOIN employee_project ep
ON e.emp_id = ep.emp_id
JOIN project p
ON p.project_id = ep.project_id;
```

---

# 7️⃣ MCP MySQL Configuration

Save as:

```
mcp.json
```

```json
{
  "mcpServers": {
    "mcp_server_mysql": {
      "command": "npx",
      "args": [
        "-y",
        "@benborla29/mcp-server-mysql"
      ],
      "env": {
        "MYSQL_HOST": "localhost",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "root",
        "MYSQL_PASS": "root123",
        "MYSQL_DB": "demo_company",

        "ALLOW_INSERT_OPERATION": "false",
        "ALLOW_UPDATE_OPERATION": "false",
        "ALLOW_DELETE_OPERATION": "false"
      }
    }
  }
}
```

---

# 8️⃣ Test MCP

Ask MCP:

```
show tables;
```

or

```
select * from employee;
```

---

# 9️⃣ Optional safer user instead of root

```sql
CREATE USER 'devuser'@'%'
IDENTIFIED BY 'dev123';

GRANT ALL PRIVILEGES
ON demo_company.*
TO 'devuser'@'%';

FLUSH PRIVILEGES;
```

Update MCP config:

```json
"MYSQL_USER": "devuser",
"MYSQL_PASS": "dev123"
```
# prompts for testing
```
"Show me all employees along with their department names and locations, sorted by salary in descending order."
This tests a basic JOIN between employee and department tables with ordering.
"Which department has the highest total salary expenditure? Show department name, location, number of employees, and total salary."
This tests aggregation (SUM, COUNT), GROUP BY, and ORDER BY with a JOIN.
"List all employees who are working on projects with a budget greater than 500000, along with their project name, role, and project budget."
This tests a multi-table JOIN across employee, employee_project, and project with a WHERE filter.
"Are there any departments that have no employees assigned to any project? Show the department name and the employee names."
This tests LEFT JOIN logic and NULL checking across three tables — useful for finding gaps in assignments.
"Give me a summary report: for each project, show the project name, budget, number of team members, and list of employee names working on it."
This tests GROUP_CONCAT, COUNT, and a multi-table JOIN — a good real-world reporting scenario.
```
---

If you want, I can also provide:

* ER diagram
* Spring Boot JPA entities
* Flyway migration script
* MCP automation to auto-create tables
* Docker compose for MySQL + MCP
