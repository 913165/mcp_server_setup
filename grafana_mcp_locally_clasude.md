
# Grafana MCP Server Local Setup

This guide walks you through setting up a Grafana MCP (Model Context Protocol) server locally to integrate Grafana with Claude Desktop.

## Prerequisites

-   Docker installed on your system
-   Claude Desktop application
-   Basic familiarity with Docker and Grafana

## Step 1: Install Grafana Locally

Run Grafana as a Docker container:

bash

```bash
docker run -d -p 3000:3000 --name=grafana grafana/grafana
```

This command:

-   Runs Grafana in detached mode (`-d`)
-   Maps port 3000 from container to host (`-p 3000:3000`)
-   Names the container "grafana" (`--name=grafana`)
-   Uses the official Grafana Docker image

## Step 2: Access Grafana Web Interface

1.  Open your web browser and navigate to `http://localhost:3000`
2.  Login with default credentials:
    -   **Username**: `admin`
    -   **Password**: `admin`
3.  You'll be prompted to change the password on first login

## Step 3: Create a New User (Optional)

If you want to create a dedicated user for the MCP server:

1.  Go to **Administration** → **Users and access** → **Users**
2.  Click **New user**
3.  Fill in the user details
4.  Set appropriate permissions
5.  Save the user

## Step 4: Create Service Account and API Token

1.  Navigate to **Administration** → **Users and access** → **Service accounts**
2.  Click **Add service account**
3.  Provide a name (e.g., "MCP Server")
4.  Set the role to **Admin** (or appropriate permissions)
5.  Click **Create**
6.  In the service account details, click **Add service account token**
7.  Provide a token name
8.  Click **Generate token**
9.  **Important**: Copy the generated token immediately - it won't be shown again

## Step 5: Configure MCP Server Settings

Add the following configuration to your Claude Desktop MCP settings file:

### Location of MCP Settings File

-   **macOS**: `~/Library/Application\ Support/Claude/claude_desktop_config.json`
-   **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

### Configuration

json

```json
{
  "mcpServers": {
    "grafana": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--network=host",
        "-e",
        "GRAFANA_URL",
        "-e",
        "GRAFANA_API_KEY",
        "mcp/grafana",
        "-t",
        "stdio"
      ],
      "env": {
        "GRAFANA_URL": "http://localhost:3000",
        "GRAFANA_API_KEY": "YOUR_SERVICE_ACCOUNT_TOKEN_HERE"
      }
    }
  }
}
```

**Replace `YOUR_SERVICE_ACCOUNT_TOKEN_HERE` with the actual service account token you generated in Step 4.**

## Step 6: Restart Claude Desktop

After saving the configuration file:

1.  Completely quit Claude Desktop application
2.  Restart Claude Desktop
3.  The MCP server should now be available

## Verification

To verify the setup is working:

1.  Open Claude Desktop
2.  Check if you can interact with Grafana through Claude
3.  Try commands related to Grafana dashboards, data sources, etc.

## Troubleshooting

### Common Issues

**Container already exists error:**

bash

```bash
docker rm grafana
docker run -d -p 3000:3000 --name=grafana grafana/grafana
```

**Port 3000 already in use:**

bash

```bash
# Check what's using port 3000
lsof -i :3000
# Kill the process or use a different port
docker run -d -p 3001:3000 --name=grafana grafana/grafana
```

**MCP server not connecting:**

-   Verify the API token is correct
-   Check that Grafana is running (`docker ps`)
-   Ensure Claude Desktop has been restarted
-   Check Claude Desktop logs for error messages

### Useful Docker Commands

bash

```bash
# Check if Grafana container is running
docker ps

# View Grafana logs
docker logs grafana

# Stop Grafana
docker stop grafana

# Start Grafana (if stopped)
docker start grafana

# Remove Grafana container
docker rm grafana
```

## Security Notes

-   The service account token provides access to your Grafana instance
-   Keep the token secure and don't share it
-   Consider using environment variables for sensitive configuration
-   Regularly rotate API tokens

## Next Steps

Once the MCP server is set up, you can:

-   Create and manage Grafana dashboards through Claude
-   Query Grafana data sources
-   Automate Grafana administrative tasks
-   Integrate Grafana workflows with other tools

## Support

If you encounter issues:

1.  Check the troubleshooting section above
2.  Verify all prerequisites are met
3.  Consult Claude Desktop and Grafana documentation
4.  Check Docker logs for error messages
