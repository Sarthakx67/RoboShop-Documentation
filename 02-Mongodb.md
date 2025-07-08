---

## 4. Component Deployment: MongoDB Server (Persistence Tier)

This section documents the detailed, step-by-step process for deploying and configuring the MongoDB server.

*   **Component Role:** MongoDB is a core part of the Persistence Tier. It serves as the NoSQL database for the RoboShop application, responsible for storing flexible, document-style data such as the product catalog information queried by the `Catalogue` microservice.
*   **Selected Version:** 4.x Series (as specified by the development team requirements)
*   **Target Operating System:** CentOS/RHEL

### 4.1. Detailed Deployment Steps

Each of the following steps is executed on the dedicated EC2 instance provisioned for MongoDB.

#### **Step 1: Configure the YUM Package Repository**
The default software repositories provided by CentOS/RHEL do not contain the official MongoDB packages. Therefore, the first step is to inform the `yum` (Yellowdog Updater, Modified) package manager where to locate and download the correct software. This is accomplished by creating a custom repository file.

*   **Action:** Create a new repository definition file using a text editor like `vim`.

    ```sh
    sudo vim /etc/yum.repos.d/mongo.repo
    ```

*   **File Content:** The following configuration is added to this file.

    ```ini
    [mongodb-org-4.2]
    name=MongoDB Repository
    baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
    gpgcheck=0
    enabled=1
    ```

*   **In-Depth Explanation of `mongo.repo`:**
    *   `[mongodb-org-4.2]`: This is the unique identifier for the repository.
    *   `name=MongoDB Repository`: A human-readable name for the repository, which is displayed during `yum` operations.
    *   `baseurl=...`: This is the most critical line. It specifies the URL where the repository's metadata and packages are located. Note the use of the `$releasever` variable, which `yum` automatically replaces with the major version of the operating system (e.g., `8`), making the file portable across different CentOS/RHEL versions.
    *   `gpgcheck=0`: This setting disables GPG signature checking for packages from this repository. In a high-security production environment, this would be set to `1`, and we would first import MongoDB's public GPG key to allow `yum` to verify the authenticity and integrity of the packages. For this project, it is disabled for simplicity.
    *   `enabled=1`: This flag explicitly enables this repository for use by `yum`.

#### **Step 2: Install the MongoDB Packages**
With the repository configured, we can now instruct `yum` to install MongoDB.

*   **Action:** Execute the installation command.

    ```sh
    sudo yum install mongodb-org -y
    ```

*   **In-Depth Explanation:**
    *   `sudo`: Executes the command with superuser (root) privileges, which are required for installing system-wide software.
    *   `yum install`: The standard command to install new packages.
    *   `mongodb-org`: This is a "meta-package." It doesn't contain much software itself, but instead defines a list of dependencies that are the actual MongoDB components (e.g., `mongodb-org-server`, `mongodb-org-mongos`, `mongodb-org-shell`). This ensures the entire, consistent toolset is installed.
    *   `-y`: This flag automatically answers "yes" to any confirmation prompts that `yum` might present. It's useful for scripting but should be used with caution in manual operations to avoid accidental installations.

#### **Step 3: Start and Enable the MongoDB Daemon**
After installation, the MongoDB service (the daemon process, named `mongod`) exists on the system but is not running. We need to start it and, more importantly, ensure it automatically restarts if the server is ever rebooted. This is managed by `systemd`, the standard Linux service manager.

*   **Action:** Use the `systemctl` utility to manage the service.

    ```sh
    sudo systemctl enable mongod
    sudo systemctl start mongod
    ```

*   **In-Depth Explanation:**
    *   `systemctl start mongod`: This command starts the `mongod` process in the current session.
    *   `systemctl enable mongod`: This is a crucial command for long-term reliability. It instructs `systemd` to create the necessary symbolic links within its configuration directories (`/etc/systemd/system/...`). This registers `mongod` to be automatically started at the appropriate time during the system's boot-up sequence (`multi-user.target`). Without this command, the database would remain offline after a server reboot.

#### **Step 4: Update Network Configuration for Remote Access**
By default, a fresh installation of MongoDB is configured for maximum security, only allowing connections that originate from the server itself (from the `localhost` interface, `127.0.0.1`). Because our application services run on different servers, they need to connect to this database over the network. We must therefore change this setting.

*   **Action:** Edit the primary MongoDB configuration file.

    ```sh
    sudo vim /etc/mongod.conf
    ```

*   **Change:** Locate the `net:` section in the file and modify the `bindIp` parameter.

    ```yaml
    # network interfaces
    net:
      port: 27017
      bindIp: 0.0.0.0  # Change from 127.0.0.1 to 0.0.0.0
    ```

*   **Action:** Apply the configuration changes by restarting the service.

    ```sh
    sudo systemctl restart mongod
    ```
    *   **Explanation:** The `mongod` daemon only reads its `.conf` file upon startup. A `restart` command is required to force it to stop the old process and launch a new one that will load our modified configuration.

### 4.2. Configuration Deep Dive: The `bindIp` Parameter

The change of the `net.bindIp` parameter in `/etc/mongod.conf` is the most significant configuration performed.
*   **What `127.0.0.1` (localhost) Means:** This is the universal "loopback" address. When a service listens on this IP, it can *only* accept connections from other processes running on the *exact same machine*. It is inaccessible from the network.
*   **What `0.0.0.0` (Unspecified IP) Means:** This address instructs the service to listen for connections on **all** network interfaces attached to the server. If the server has a private IP (e.g., `10.0.1.15`) and a public IP (e.g., `54.x.x.x`), the service will accept connections on port 27017 from either.
*   **The Security Model (Defense in Depth):** While listening on `0.0.0.0` might seem insecure, it is a standard practice within a cloud environment when coupled with an infrastructure-level firewall. In this project, **AWS Security Groups** provide this firewall. The Security Group attached to the MongoDB EC2 instance is configured with a strict inbound rule that only allows TCP traffic on port `27017` from a specific source—the Security Group ID of our application tier instances. All other traffic from the internet or other parts of the VPC is dropped by AWS before it can even reach the server.

### 4.3. Verification and Health Checks

Deployment without verification is incomplete. The following checks confirm that the service is running and configured correctly.

1.  **Check Service Status with `systemd`:** Confirm that the process is actively managed by the OS.
    ```sh
    sudo systemctl status mongod
    ```
    *   **Expected Outcome:** A green `active (running)` message is displayed, along with process information and recent log entries. If it is red and `failed`, it indicates a startup problem.

2.  **Validate Network Listening Port:** Verify that `mongod` is listening on all network interfaces.
    ```sh
    # 'ss' is a modern tool to investigate sockets. '-lntp' options mean:
    # -l: Show listening sockets
    # -n: Do not resolve service names (show port numbers)
    # -t: Display TCP sockets
    # -p: Show the process using the socket
    sudo ss -lntp | grep mongod
    ```
    *   **Expected Outcome:** The output must contain the line `0.0.0.0:27017`. If it shows `127.0.0.1:27017`, the configuration change was not applied correctly.

3.  **Perform a Test Connection:** Use the MongoDB shell client to make a direct local connection to the database server and run a simple command.
    ```sh
    # The --eval option executes a JavaScript command and exits.
    # db.stats() returns statistics for the current database.
    mongo --eval 'db.stats()'
    ```
    *   **Expected Outcome:** A successful connection followed by a JSON output containing database statistics. This proves the daemon is not just listening but is fully operational and responsive.

### 4.4. Troubleshooting Guide

| Problem Scenario                              | Common Causes and Detailed Solutions                                                                                                                                                                                                                            |
|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `systemctl start mongod` fails immediately.   | **1. Configuration Syntax Error:** The most common cause. The `mongod.conf` file uses YAML format, which is very sensitive to indentation. Check for typos or improper spacing and review the logs (`sudo journalctl -u mongod -e`) for specific error messages pointing to a line number. <br> **2. File Permissions:** The `/var/lib/mongo` and `/var/log/mongodb` directories may have incorrect ownership. Ensure they are owned by the `mongod` user (`sudo chown -R mongod:mongod /var/lib/mongo`). |
| Application server cannot connect (Timeout).    | **1. AWS Security Group:** This is the #1 suspect. The Security Group for the MongoDB instance **must** have an inbound rule allowing TCP traffic on port `27017`. The source for this rule must be either the specific private IP of the application server or, preferably, the Security Group ID of the application tier. <br> **2. Incorrect `bindIp`:** Verify the output of `ss -lntp | grep mongod` shows `0.0.0.0`. If not, re-edit `/etc/mongod.conf` and restart the service. |
| Authentication Error from Application.      | This manual deployment does not configure a username/password. If you see authentication errors, it means a previous or different configuration enabled `auth: true` in `mongod.conf`. For this project, ensure the `security:` section is either absent or commented out. Adding authentication would be a next step to further secure the deployment. |