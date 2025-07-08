---

### Component Deployment: MySQL Server (Persistence Tier)

This section documents the deployment of the MySQL 5.7 server. This service is a core component of the Persistence Tier, responsible for storing relational data such as user account and shipping information. The deployment on a CentOS/RHEL 8-based system requires a specific process to downgrade from the default MySQL 8.0 module.

#### Deployment Steps

1.  **System Cleanup: Remove Conflicting Packages**
    Before installation, we must ensure a clean slate by removing any pre-installed packages (like `mariadb`) that would conflict with MySQL 5.7. This prevents installation failures due to file conflicts.
    ```sh
    sudo yum remove mysql mariadb mariadb-libs mariadb-connector-c-config -y
    ```

2.  **Disable Default MySQL Module**
    CentOS/RHEL 8 includes a built-in `mysql:8.0` module. We must explicitly disable this module to allow the system to see and install the older 5.7 version we require.
    ```sh
    sudo yum module disable mysql -y
    ```

3.  **Install the Official MySQL 5.7 Repository**
    Instead of manually creating a `.repo` file (which is prone to error), the correct method is to install the official RPM from MySQL. This file is specifically for EL8 and correctly configures the `yum` repositories.
    ```sh
    sudo yum install https://dev.mysql.com/get/mysql57-community-release-el8-*.rpm -y
    ```

4.  **Install MySQL Server**
    With the conflicts removed and the correct repository configured, the MySQL 5.7 server can now be installed successfully.
    ```sh
    sudo yum install mysql-community-server -y
    ```

5.  **Start and Enable the Service**
    Start the `mysqld` service and enable it to ensure it automatically launches on server reboot.
    ```sh
    sudo systemctl enable mysqld
    sudo systemctl start mysqld
    ```

6.  **Set Initial Root Password (The Robust Method)**
    MySQL 5.7 generates a random temporary password for the `root` user. The `mysql_secure_installation` script is unreliable for this initial setup. The correct process is to find this password and use it to set a new one.
    *   **Action 1: Find the temporary password.**
        ```sh
        sudo grep 'temporary password' /var/log/mysqld.log
        ```
    *   **Action 2: Set the new root password.** Log in with the temporary password and use the `ALTER USER` command. **Replace `'TEMP_PASSWORD_FROM_LOG'` with the password you just found.**
        ```sh
        # Note: You will be prompted to enter the temporary password.
        mysql -u root -p'TEMP_PASSWORD_FROM_LOG' --connect-expired-password

        # Once inside the MySQL prompt, run the following SQL command:
        ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';
        ```
        You can then type `exit`.

7.  **Create Application Users**
    For applications to connect, they need their own specific users and privileges.
    *   **Action:** Log back in with the new root password and run the following SQL commands.
        ```sh
        # Log in with the permanent password
        mysql -uroot -p'RoboShop@1'

        # Inside the MySQL prompt, run these commands:
        CREATE USER 'roboshop'@'%' IDENTIFIED BY 'RoboShop@1';
        GRANT ALL PRIVILEGES ON *.* TO 'roboshop'@'%';

        CREATE USER 'shipping'@'%' IDENTIFIED BY 'RoboShop@1';
        GRANT ALL PRIVILEGES ON *.* TO 'shipping'@'%';
        
        FLUSH PRIVILEGES;
        exit;
        ```

#### Configuration Deep Dive: From Fragile to Robust
This deployment deviates from simple tutorials for several key reasons that reflect real-world challenges:
*   **Repository Management:** Simply copying an old `.repo` file for EL7 onto an EL8 system is incorrect and causes modularity filters to block the install. The robust solution is to **disable the native module** and **install the official vendor repository RPM** built for EL8.
*   **Conflict Resolution:** Fresh servers are not always clean. Pre-existing `mariadb` packages will cause the MySQL installation to fail. A preliminary cleanup step is a professional best practice.
*   **Password Initialization:** The initial password flow for MySQL 5.7 is often misunderstood. Grepping the log for the temporary password and using `ALTER USER` is the definitive method to reliably set the root password, bypassing issues with expired passwords or special characters.

#### Verification and Health Checks

1.  **Check Service Status:** Verify the `mysqld` process is active.
    ```sh
    sudo systemctl status mysqld
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Validate Root Login:** The most important check is to confirm that the new root password works correctly.
    ```sh
    # This command attempts to log in and immediately run 'SHOW DATABASES;'
    mysql -uroot -p'RoboShop@1' -e "SHOW DATABASES;"
    ```
    *   **Expected Outcome:** A successful login and a list of the default MySQL databases, with no "Access denied" errors.

#### Troubleshooting Guide

| Problem                                          | Possible Cause & Solution                                                                                                                                                                                                            |
|--------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `yum install mysql-community-server` fails.      | **1. Conflicting Packages:** You did not run the initial cleanup (`sudo yum remove...`). <br> **2. Module Not Disabled:** You did not run `sudo yum module disable mysql -y`. <br> **3. Wrong Repository:** You did not install the official EL8 repo RPM correctly. |
| Access denied for `root`@`localhost`.           | **1. Wrong Password:** You may have a typo in the temporary password you found, or the `RoboShop@1` password you are trying to use. Retrace the steps in "Set Initial Root Password" carefully.                                           |
| Access denied for an application user (`shipping`). | **1. User Not Created:** You missed "Step 7: Create Application Users". Log in as root and create the specific user the application requires. <br> **2. Wrong Host:** We used `'shipping'@'%'` which allows connection from any host. Some configurations might require `'shipping'@'localhost'` or `'shipping'@'<IP_ADDRESS>'`. `%` is a good default for this project. |