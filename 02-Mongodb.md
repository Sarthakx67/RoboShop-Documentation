### 4.1. MongoDB Service Deployment (Database Tier)

This section details the steps taken to install and configure the MongoDB server.

*   **Component:** MongoDB Server
*   **Version:** 4.2
*   **Operating System:** CentOS/RHEL
*   **Purpose:** MongoDB serves as the NoSQL database for storing the product catalog and other non-relational data for the RoboShop application.

---

#### **Step 1: Configure the YUM Repository**

The first step is to configure the system's package manager (`yum`) to locate the official MongoDB packages, as they are not available in the default OS repositories.

*   **Action:** Create a new repository file.

    ```sh
    sudo vim /etc/yum.repos.d/mongo.repo
    ```

*   **File Content:** Add the following configuration to the `mongo.repo` file. This tells `yum` where to find the specified version of MongoDB.

    ```ini
    [mongodb-org-4.2]
    name=MongoDB Repository
    baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
    gpgcheck=0
    enabled=1
    ```

#### **Step 2: Install MongoDB**

With the repository configured, proceed to install the MongoDB package.

*   **Action:** Execute the installation command.

    ```sh
    sudo yum install mongodb-org -y
    ```
    *Note: The `-y` flag automatically accepts the confirmation prompt, which is useful for scripting.*

#### **Step 3: Start and Enable the MongoDB Service**

This ensures the database process starts immediately and is also configured to launch automatically on server reboot.

*   **Action:** Start and enable the `mongod` service using `systemctl`.

    ```sh
    sudo systemctl enable mongod
    sudo systemctl start mongod
    ```
    *`enable` ensures the service starts on boot. `start` runs the service in the current session.*

#### **Step 4: Update Network Configuration for Remote Access**

By default, MongoDB only allows connections from `localhost` (the server it's running on). This must be changed to allow the application microservices (running on other servers) to connect to it.

*   **Action:** Edit the MongoDB configuration file.

    ```sh
    sudo vim /etc/mongod.conf
    ```

*   **Change:** Locate the `net` section and update the `bindIp` value from `127.0.0.1` to `0.0.0.0`.

    ```yaml
    # network interfaces
    net:
      port: 27017
      bindIp: 0.0.0.0  # Listen on all network interfaces
    ```

*   **Purpose:** This change instructs MongoDB to listen for incoming connections on all available network interfaces of the server, not just the local loopback address. **Security is managed separately at the infrastructure level using cloud firewall rules (Security Groups).**

#### **Step 5: Restart the Service to Apply Changes**

The MongoDB service must be restarted to load the new network configuration.

*   **Action:** Restart the `mongod` service.

    ```sh
    sudo systemctl restart mongod
    ```

#### **Step 6: Verification**

To confirm that the changes were applied correctly, you can check the network status to see which address the `mongod` process is listening on.

*   **Action:** Use the `ss` or `netstat` command.

    ```sh
    # This command lists all listening TCP ports and filters for the mongod process
    sudo ss -lntp | grep mongod
    ```
    
*   **Expected Output:** The output should show that the `mongod` process is listening on `0.0.0.0:27017`, confirming it is accessible over the network.