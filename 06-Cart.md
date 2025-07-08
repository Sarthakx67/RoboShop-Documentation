---

### Component Deployment: Cart Service (Application Tier)

This section outlines the deployment for the Cart microservice. This NodeJS application manages shopping cart activities, such as adding, removing, and viewing items. It relies on the Redis server for data storage and communicates with the Catalogue service to fetch product details.

#### Deployment Steps

1.  **Install NodeJS Runtime**
    The `yum` package manager is configured with the NodeSource repository to allow for the installation of the required NodeJS LTS (Long-Term Support) runtime.
    ```sh
    # Add the NodeSource repository for NodeJS
    curl -sL https://rpm.nodesource.com/setup_lts.x | sudo bash
    # Install the NodeJS package
    sudo yum install nodejs -y
    ```

2.  **Create Application User and Directory**
    A dedicated `roboshop` system user is created for security, and a standard `/app` directory is set up to house the application's code.
    ```sh
    sudo useradd roboshop
    sudo mkdir /app
    ```

3.  **Download and Unpack the Application Artifact**
    The Cart service's pre-packaged code is downloaded as a `.zip` artifact and then extracted into the `/app` directory.
    ```sh
    curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
    cd /app
    sudo unzip /tmp/cart.zip
    ```

4.  **Install Application Dependencies**
    The `npm` utility is used to install all the third-party libraries defined in the `package.json` file that are required for the application to run.
    ```sh
    cd /app
    sudo npm install
    ```

5.  **Configure Systemd Service**
    A `systemd` service file is created at `/etc/systemd/system/cart.service`. This file allows the operating system to manage the Cart service as a persistent background daemon.
    *   **Action:** Create the service file. **Note: The IP addresses for the Redis and Catalogue servers are placeholders and must be replaced.**
        ```ini
        [Unit]
        Description=Cart Service

        [Service]
        User=roboshop
        Environment=REDIS_HOST=<REDIS-SERVER-IP-ADDRESS>
        Environment=CATALOGUE_HOST=<CATALOGUE-SERVER-IP-ADDRESS>
        Environment=CATALOGUE_PORT=8080
        ExecStart=/bin/node /app/server.js
        SyslogIdentifier=cart

        [Install]
        WantedBy=multi-user.target
        ```

6.  **Start and Enable the Service**
    Reload the `systemd` manager to read the new service definition, then start the service and enable it to launch automatically on server boot.
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl enable cart
    sudo systemctl start cart
    ```

#### Configuration Deep Dive: Service-to-Service Communication
The Cart service is a clear example of inter-service communication within a microservices architecture. It does not connect to a primary database itself. Instead, it relies on two other services:
*   **Redis (`REDIS_HOST`):** It uses Redis as its database to store the contents of user shopping carts. This is a good design choice for ephemeral, high-turnover data.
*   **Catalogue Service (`CATALOGUE_HOST`):** When a user wants to see their cart, the Cart service needs to get product details (like name and price). It fetches this by making an API call to the Catalogue service.
The use of environment variables to define these endpoints is critical for maintaining decoupling between the services.

#### Verification and Health Checks

1.  **Check Service Status:** Verify the Cart service has started and is running correctly using `systemctl`.
    ```sh
    sudo systemctl status cart
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Review Application Logs:** Inspect the logs for successful startup messages and to confirm it has connected to its dependencies.
    ```sh
    sudo journalctl -u cart -e
    ```
    *   **Expected Outcome:** Messages indicating the service is running, with no errors related to Redis or the Catalogue host.

3.  **Test Local API Endpoint:** Use `curl` to test an API endpoint. Since fetching a cart requires a user ID, this may require more specific testing, but a health check is a good first step.
    ```sh
    # Assuming a GET endpoint exists like this, substituting a cartId
    curl http://localhost:8080/api/cart/123
    ```
    *   **Expected Outcome:** A JSON response, which might be an empty cart if the ID is new, or an error message if the format is wrong. A successful HTTP `200 OK` is a good sign.

#### Troubleshooting Guide

| Problem                                | Possible Cause & Solution                                                                                                                                                                                                                                                          |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Service is `failed` or in a crash loop. | **1. `npm install` Errors:** Check the log of the `npm` command for failed library downloads. <br> **2. Port Conflict:** The port `8080` may be in use by another service on this machine. Check with `sudo ss -lntp`. <br> **3. Missing Dependency:** The service may exit if it cannot find Redis or the Catalogue host on startup. Check logs. |
| Logs show connection errors.           | **1. Incorrect IP Addresses:** The IPs for `REDIS_HOST` or `CATALOGUE_HOST` in `/etc/systemd/system/cart.service` are wrong. Verify the IPs, then run `daemon-reload` and restart the service. <br> **2. Security Groups:** A firewall is blocking the connection. Ensure the Security Group for the Redis or Catalogue server allows inbound traffic on the appropriate port (`6379` for Redis, `8080` for Catalogue) from this Cart server. |
| Cart API calls are failing or slow.    | **1. Upstream Service is Down:** The Redis or Catalogue service itself might be offline. Use their health check steps to verify their status. <br> **2. Network Latency:** High latency between the availability zones of the instances could be a factor. |