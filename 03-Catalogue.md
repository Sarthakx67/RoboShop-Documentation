---

### Component Deployment: Catalogue Service (Application Tier)

This section outlines the deployment process for the Catalogue microservice. This NodeJS application is a key part of the Application Tier, responsible for handling all API requests related to product information and communicating with the MongoDB server.

#### Deployment Steps

1.  **Install NodeJS Runtime**
    The application requires the NodeJS runtime. We first use a vendor-provided script to add the NodeSource LTS (Long-Term Support) repository, then install NodeJS using `yum`.
    ```sh
    # This script adds the necessary yum repository for NodeJS
    curl -sL https://rpm.nodesource.com/setup_lts.x | sudo bash

    # Install the NodeJS package
    sudo yum install nodejs -y
    ```

2.  **Create Application User and Directory**
    For security and organization, we create a dedicated system user (`roboshop`) to run the application and a standard directory (`/app`) to hold its code.
    ```sh
    sudo useradd roboshop
    sudo mkdir /app
    ```

3.  **Download and Unpack the Application Artifact**
    The application code is downloaded as a `.zip` artifact from a remote source and then unzipped into the `/app` directory.
    ```sh

    curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
    cd /app
    sudo unzip /tmp/catalogue.zip
    ```

4.  **Install Application Dependencies**
    NodeJS projects use `npm` (Node Package Manager) to install required libraries defined in the `package.json` file.
    ```sh
    cd /app
    # This command reads the package.json and downloads libraries
    sudo npm install
    ```

5.  **Configure Systemd Service**
    A `systemd` service file is created to allow the operating system to manage the application lifecycle (start, stop, restart, enable on boot).
    *   **Action:** Create the file `/etc/systemd/system/catalogue.service`. **Note: The MongoDB IP address is a placeholder and must be replaced.**
        ```ini
        [Unit]
        Description=Catalogue Service

        [Service]
        User=roboshop
        Environment=MONGO=true
        Environment=MONGO_URL="mongodb://<MONGODB-SERVER-IPADDRESS>:27017/catalogue"
        ExecStart=/bin/node /app/server.js
        SyslogIdentifier=catalogue

        [Install]
        WantedBy=multi-user.target
        ```

6.  **Start and Enable the Service**
    Reload the `systemd` configuration to recognize the new service file, then start the service and enable it to launch on boot.
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl enable catalogue
    sudo systemctl start catalogue
    ```

7.  **Load Database Schema**
    This one-time setup populates the database with the necessary product data. It requires installing the `mongo` shell on the Catalogue server and then executing the schema script against the MongoDB server.
    *   **Action:** Install the client, then load the schema. **The MongoDB IP must be replaced here as well.**
        ```sh
        sudo yum install mongodb-org-shell -y
        mongo --host <MONGODB-SERVER-IPADDRESS> </app/schema/catalogue.js
        ```

#### Configuration Deep Dive: Environment Variables in `systemd`
The `catalogue.service` file contains a critical configuration strategy: the use of **Environment Variables**.
*   **`Environment=MONGO_URL=...`**: Instead of hardcoding the database connection details into the application's source code, we provide it via an environment variable. This is a crucial best practice that decouples the application from its environment. It allows the same application code artifact to be promoted across different stages (e.g., from dev to QA to production) by simply providing a different `MONGO_URL` in each environment. It's a clean way to manage external service dependencies.

#### Verification and Health Checks

1.  **Check Service Status:** Verify the Catalogue service process is active.
    ```sh
    sudo systemctl status catalogue
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Review Application Logs:** Inspect the logs for successful startup messages, especially the connection to MongoDB.
    ```sh
    # The '-e' flag jumps to the end of the logs
    sudo journalctl -u catalogue -e
    ```
    *   **Expected Outcome:** You should see messages like "connected to mongodb" and "server running on port 8080".

3.  **Test Local API Endpoint:** Use `curl` to send a request to the service running on localhost. This confirms the application is serving traffic.
    ```sh
    # The jq tool formats the JSON output for readability.
    curl -s http://localhost:8080/api/catalogue/products | jq .
    ```
    *   **Expected Outcome:** A formatted JSON array of product information.

#### Troubleshooting Guide

| Problem                                | Possible Cause & Solution                                                                                                                                                                                                            |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Service is `failed` or won't start.      | **1. `npm install` failed:** Check for errors during the `npm install` process. <br> **2. Permissions Issue:** Ensure the `/app` directory is owned by the `roboshop` user (`sudo chown -R roboshop:roboshop /app`). <br> **3. Config Typo:** A syntax error in the `/etc/systemd/system/catalogue.service` file. |
| Logs show "Could not connect to MongoDB".| **1. Incorrect IP:** The `MONGO_URL` in the `.service` file has the wrong IP. Correct it, then run `sudo systemctl daemon-reload` and `sudo systemctl restart catalogue`. <br> **2. Security Group:** The MongoDB server's Security Group is blocking traffic from the Catalogue server's Security Group on port 27017. |
| `mongo --host ...` command fails.        | **1. Package Missing:** The `mongodb-org-shell` was not installed. Run `sudo yum install mongodb-org-shell -y`. <br> **2. Networking Issue:** A "No route to host" or "Timeout" error indicates a network problem (like a Security Group block) between the Catalogue and MongoDB servers. |

#### Final Configuration Step

**IMPORTANT:** For the entire application to work, the `Frontend (Nginx)` service must be updated. The Nginx configuration file (`/etc/nginx/default.d/roboshop.conf`) contains a `proxy_pass` directive for the catalogue service that must be updated to point to the IP address of this Catalogue server.