---

### Component Deployment: Redis (Persistence Tier)

This section covers the deployment of the Redis server. Redis serves as a high-speed, in-memory key-value store. In the RoboShop architecture, its primary role is caching user session data to reduce latency and decrease load on the primary databases.

#### Deployment Steps

1.  **Install Remi Repository**
    To get a modern version of Redis, we first need to install the "Remi" repository, a trusted third-party source for up-to-date packages on RHEL/CentOS systems.
    ```sh
    sudo yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
    ```

2.  **Enable Redis Module Stream**
    Modern RHEL/CentOS systems use "module streams" to provide multiple versions of software. We explicitly enable the Redis 6.2 stream from the Remi repository.
    ```sh
    sudo yum module enable redis:remi-6.2 -y
    ```

3.  **Install Redis**
    With the correct repository and module stream enabled, we can now install the Redis package.
    ```sh
    sudo yum install redis -y
    ```

4.  **Update Network Configuration for Remote Access**
    By default, Redis only listens for connections on `localhost`. This must be changed to allow application services on other servers to connect to it.

    *   **Action:** Edit the Redis configuration file. Find the line `bind 127.0.0.1` and change it to `bind 0.0.0.0`.
    *   **Note on File Location:** Depending on the OS version and installation source, this file can be at `/etc/redis.conf` or `/etc/redis/redis.conf`. Check both locations and edit the one that exists.

        ```sh
        # Check and edit one of these files
        sudo vim /etc/redis.conf
        # OR
        sudo vim /etc/redis/redis.conf
        ```

5.  **Start and Enable the Service**
    Finally, we start the Redis service and enable it to launch automatically upon server reboot.
    ```sh
    sudo systemctl enable redis
    sudo systemctl start redis
    ```

#### Configuration Deep Dive: Redis `bind` Directive
Similar to MongoDB, the `bind 0.0.0.0` directive tells Redis to accept connections on all available network interfaces. This is a required step for our distributed architecture. Security is maintained at the cloud infrastructure level by a precisely configured **AWS Security Group**, which acts as a firewall. It is configured to only allow inbound traffic on the Redis port (`6379`) from the application tier, effectively preventing unauthorized external access.

#### Verification and Health Checks

1.  **Check Service Status:** Verify the `redis-server` process is running correctly.
    ```sh
    sudo systemctl status redis
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Validate Listening Address:** Confirm Redis is listening on the correct network interface.
    ```sh
    sudo ss -lntp | grep redis-server
    ```
    *   **Expected Outcome:** The output must show the service listening on `0.0.0.0:6379`.

3.  **Perform Local Test Connection:** Use the `redis-cli`, the official command-line interface, to send a `PING` command. This is the standard health check for Redis.
    ```sh
    redis-cli ping
    ```
    *   **Expected Outcome:** The server should immediately reply with `PONG`. This confirms it is alive and responsive.

#### Troubleshooting Guide

| Problem                                  | Possible Cause & Solution                                                                                                                                                                                                            |
|------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Service fails to start after editing config. | **1. Config Error:** A syntax error in the `.conf` file is the most likely culprit. Redis is sensitive to invalid directives. Check the logs (`sudo journalctl -u redis -e`) for specific error messages that point to the problem line. <br> **2. Permissions:** Unlikely with a package install, but check folder permissions on `/var/lib/redis` if logs indicate issues. |
| Connection times out from another server. | **1. AWS Security Group:** Almost always the cause. The Redis server's Security Group must allow inbound TCP traffic on port `6379` from the source IP or Security Group of the connecting application server. <br> **2. `bind` directive:** Double-check the config file to ensure `bind 0.0.0.0` is set and `bind 127.0.0.1` is commented out or removed. Restart the service after any change. |
| `yum module enable` command fails.       | **1. Repo Not Found:** The Remi repo RPM did not install correctly. Try the installation command again. <br> **2. Conflicting Module:** Another module might be enabled. Try `yum module reset redis` and then rerun the `enable` command. |