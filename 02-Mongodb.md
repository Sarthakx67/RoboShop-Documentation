---

### Component Deployment: MongoDB Server (Persistence Tier)

This section details the manual deployment process for the MongoDB server. As a core component of the Persistence Tier, MongoDB stores the product catalog data accessed by the `Catalogue` microservice.

#### Deployment Steps

1.  **Configure YUM Repository**
    First, we must inform the system's package manager (`yum`) where to find the official MongoDB packages by creating a custom repository file.

    *   **Action:** Create and populate `/etc/yum.repos.d/mongo.repo`.
        ```ini
        [mongodb-org-4.2]
        name=MongoDB Repository
        baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
        gpgcheck=0
        enabled=1
        ```

2.  **Install MongoDB**
    With the repository in place, we can now install the `mongodb-org` meta-package, which includes the database server, shell, and other necessary tools.

    *   **Action:** Install using `yum`.
        ```sh
        sudo yum install mongodb-org -y
        ```

3.  **Start and Enable the Service**
    This step starts the MongoDB process (`mongod`) and, crucially, enables it to start automatically on system boot, ensuring service reliability.

    *   **Action:** Use `systemctl` to start and enable the daemon.
        ```sh
        sudo systemctl enable mongod
        sudo systemctl start mongod
        ```

4.  **Update Network Configuration for Remote Access**
    To allow our other microservices to connect to this database over the network, we must change its default network binding from `localhost` to listen on all network interfaces.

    *   **Action:** Edit the `/etc/mongod.conf` file to change the `net.bindIp` parameter from `127.0.0.1` to `0.0.0.0`.

5.  **Restart the Service**
    The MongoDB service must be restarted to apply the network configuration change.

    *   **Action:** Restart the `mongod` service.
        ```sh
        sudo systemctl restart mongod
        ```

#### Configuration Deep Dive: `bindIp` and Security
The most critical change is setting `net.bindIp` to `0.0.0.0`. This makes MongoDB accessible from outside the local machine. While this sounds insecure, it's a standard practice in a cloud VPC when paired with a "defense-in-depth" security model. Access is not controlled at the application level but at the infrastructure level via **AWS Security Groups**. The Security Group for this instance is configured with a strict inbound rule to only allow traffic on port `27017` from the application tier's security group, effectively blocking all other external connection attempts.

#### Verification and Health Checks

1.  **Check Service Status:** Verify the `mongod` process is active and running correctly.
    ```sh
    sudo systemctl status mongod
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Validate Listening Address:** Confirm MongoDB is listening on all network interfaces.
    ```sh
    sudo ss -lntp | grep mongod
    ```
    *   **Expected Outcome:** The output must show the service listening on `0.0.0.0:27017`.

3.  **Perform Local Test Connection:** Run a simple command using the Mongo shell to confirm the database is responsive.
    ```sh
    mongo --eval 'db.stats()'
    ```
    *   **Expected Outcome:** A successful connection followed by a JSON output of database statistics.

#### Troubleshooting Guide

| Problem                                  | Possible Cause & Solution                                                                                                                                                                                                            |
|------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Service fails to start after a change.   | **1. Config Error:** A typo or YAML formatting error in `/etc/mongod.conf` is likely. Check the logs (`sudo journalctl -u mongod -e`) for specific error messages. <br> **2. Permissions:** Directory ownership for `/var/lib/mongo` might be wrong. |
| Connection times out from another server. | **1. AWS Security Group:** The #1 cause. Ensure the MongoDB instance's Security Group allows inbound TCP traffic on port `27017` from the source IP or Security Group of your application server. <br> **2. `bindIp` Not Set:** Verify that `ss -lntp` shows the service is listening on `0.0.0.0`, not `127.0.0.1`. If not, re-edit the config and restart. |