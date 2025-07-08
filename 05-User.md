---

### Component Deployment: User Service (Application Tier)

This section details the deployment of the User microservice. This is a NodeJS application that handles all user-centric operations, including registration, login, and profile management. It communicates with both MongoDB to store user data and Redis to cache user sessions.

#### Deployment Steps

1.  **Install NodeJS Runtime**
    The NodeSource repository is added to provide the `yum` package manager with access to the NodeJS LTS (Long-Term Support) runtime, which is then installed.
    ```sh
    # Set up the NodeJS yum repository
    curl -sL https://rpm.nodesource.com/setup_lts.x | sudo bash
    # Install the NodeJS runtime
    sudo yum install nodejs -y
    ```

2.  **Create Application User and Directory**
    A dedicated `roboshop` system user and a standard `/app` directory are created to ensure secure and organized code deployment.
    ```sh
    sudo useradd roboshop
    sudo mkdir /app
    ```

3.  **Download and Unpack the Application Artifact**
    The pre-packaged application code for the User service is downloaded from a remote S3 bucket and unzipped into the `/app` directory.
    ```sh
    curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
    cd /app
    sudo unzip /tmp/user.zip
    ```

4.  **Install Application Dependencies**
    The `npm` (Node Package Manager) utility is used to read the `package.json` file and install all the necessary third-party libraries for the application to function.
    ```sh
    cd /app
    sudo npm install
    ```

5.  **Configure Systemd Service**
    A `systemd` service file is created at `/etc/systemd/system/user.service` to allow the operating system to manage the application as a background service.
    *   **Action:** Create the service file. **Note: The IP addresses for Redis and MongoDB are placeholders and must be replaced.**
        ```ini
        [Unit]
        Description=User Service

        [Service]
        User=roboshop
        Environment=MONGO=true
        Environment=REDIS_HOST=<REDIS-SERVER-IP-ADDRESS>
        Environment=MONGO_URL="mongodb://<MONGODB-SERVER-IP-ADDRESS>:27017/users"
        ExecStart=/bin/node /app/server.js
        SyslogIdentifier=user

        [Install]
        WantedBy=multi-user.target
        ```

6.  **Start and Enable the Service**
    The `systemd` manager is reloaded to read the new service definition, and the service is started and enabled to launch on server boot.
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl enable user
    sudo systemctl start user
    ```

7.  **Load Database Schema**
    This final step loads the initial data structure required by the User service into the database. This requires installing the MongoDB client on this server first.
    *   **Action:** Install the client tools, then execute the schema loading script. **The MongoDB IP must be replaced here.**
        ```sh
        # If not already present, install the mongo shell
        sudo yum install mongodb-org-shell -y
        mongo --host <MONGODB-SERVER-IP-ADDRESS> </app/schema/user.js
        ```

#### Configuration Deep Dive: Managing Multiple Dependencies
A key aspect of this service is its reliance on multiple downstream components (MongoDB and Redis). The `user.service` file manages this cleanly through environment variables:
*   `Environment=MONGO_URL=...`
*   `Environment=REDIS_HOST=...`
This demonstrates a core principle of microservice architecture: a service's external dependencies should be treated as attached resources whose connection details are injected into the environment. This keeps the application code portable and free of environment-specific details.

#### Verification and Health Checks

1.  **Check Service Status:** Use `systemctl` to ensure the `user` service is running correctly.
    ```sh
    sudo systemctl status user
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Review Application Logs:** Inspect the `journalctl` logs for startup messages and potential errors.
    ```sh
    sudo journalctl -u user -e
    ```
    *   **Expected Outcome:** Messages indicating a successful connection to both MongoDB and Redis.

3.  **Test Local API Endpoint:** While this service requires request data for many of its endpoints, checking its health endpoint (if available) with `curl` is a good verification step.
    ```sh
    # Assuming a /health endpoint exists
    curl http://localhost:8080/health
    ```
    *   **Expected Outcome:** A confirmation message, e.g., `{"status": "ok"}`.

#### Troubleshooting Guide

| Problem                                      | Possible Cause & Solution                                                                                                                                                                                                                                                                    |
|----------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Service fails to start or enters a crash loop. | **1. `npm install` Failed:** Review logs for errors related to missing modules. <br> **2. Typos in `.service` File:** Double-check the file paths and environment variable names. <br> **3. Port Conflict:** Another service on the machine may already be using port `8080`. Check with `sudo ss -lntp`. |
| Logs show "Could not connect to..."          | **1. Incorrect IP Address:** The `#1` cause. The IP addresses for `MONGO_URL` or `REDIS_HOST` in the `.service` file are wrong. Verify them, then run `daemon-reload` and restart the service. <br> **2. Security Groups:** The relevant Security Group (for Redis or Mongo) is not allowing traffic from this User server. Check the inbound rules on the destination Security Group to ensure it allows traffic on port `27017` (Mongo) or `6379` (Redis) from this server's IP or Security Group. |
| The `mongo --host ...` schema load fails.      | **1. Networking Issue:** This indicates a fundamental network problem (firewall, routing) between the User server and the MongoDB server. <br> **2. Mongo Client Not Installed:** Ensure `mongodb-org-shell` was installed successfully.                                                     |