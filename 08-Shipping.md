---

### Component Deployment: Shipping Service (Application Tier)

This section details the corrected and robust manual deployment process for the Shipping microservice. This is a Java-based application that calculates shipping costs, depending on MySQL for data and the Cart service for cart information. The following steps incorporate fixes for common issues related to the build process, database schema, and data loading.

#### Deployment Steps

1.  **Install Dependencies**
    We need to install `maven` to build the application and the `mysql` client to interact with the database. Maven will pull in Java as a dependency.
    ```sh
    sudo yum install maven mysql -y
    ```

2.  **Create Application User and Directory**
    A non-login `roboshop` user is created for security, and a standard `/app` directory will hold the application code.
    ```sh
    sudo useradd roboshop
    sudo mkdir /app
    ```

3.  **Download and Unpack Application Source**
    The application source code is downloaded as a `.zip` artifact and then extracted.
    ```sh
    curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
    cd /app
    sudo unzip /tmp/shipping.zip
    ```

4.  **Build the Application with Maven**
    We now compile the Java source code and package it into a self-contained, executable JAR file. This is a critical step for Java applications.
    ```sh
    cd /app
    sudo mvn clean package
    ```

5.  **Configure Systemd Service**
    The `systemd` service file is created to manage the application. It's crucial that `ExecStart` points to the correct JAR file created by Maven.
    *   **Action:** Create the file `/etc/systemd/system/shipping.service`. **Note: The IP addresses and password are placeholders and must be replaced.**
        ```ini
        [Unit]
        Description=Shipping Service

        [Service]
        User=roboshop
        Environment="CART_ENDPOINT=<CART-SERVER-IP-ADDRESS>:8080"
        Environment="DB_HOST=<MYSQL-SERVER-IP-ADDRESS>"
        Environment="DB_USER=shipping"
        Environment="DB_PASS=RoboShop@1"
        ExecStart=/usr/bin/java -jar /app/target/shipping-1.0.jar
        SyslogIdentifier=shipping

        [Install]
        WantedBy=multi-user.target
        ```

6.  **Load, Correct, and Populate the Database Schema**
    This is a multi-step process to prepare the database. The application has specific expectations about the schema that must be met manually.
    *   **Action 1: Load the base schema.** This creates the `cities` database and a table within it named `cities`. **Replace the IP and password.**
        ```sh
        mysql -h <MYSQL-SERVER-IP> -ushipping -pRoboShop@1 < /app/db/schema.sql
        ```
    *   **Action 2: Rename the table.** The application code expects the table to be named `codes`, not `cities`. We must rename it.
        ```sh
        mysql -h <MYSQL-SERVER-IP> -ushipping -pRoboShop@1 cities -e "RENAME TABLE cities TO codes;"
        ```
    *   **Action 3: Load the master data.** The `codes` table must be populated with data for the application to function.
        ```sh
        mysql -h <MYSQL-SERVER-IP> -ushipping -pRoboShop@1 cities < /app/db/master-data.sql
        ```

7.  **Start and Enable the Service**
    With the application built and the database correctly prepared, we can now start the Shipping service and enable it to run on boot.
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl enable shipping
    sudo systemctl start shipping
    ```

#### Configuration Deep Dive: Solving the "Works on My Machine" Problem
The successful deployment of this service required solving several "real-world" issues not present in simple tutorials:
*   **Correct Executable Path:** The `ExecStart` command must point to the JAR file that Maven *builds* (e.g., `/app/target/shipping-1.0.jar`), not just a file in the root directory. This solves the `no main manifest attribute` Java error.
*   **Explicit Database Credentials:** The application code is hard-coded to connect as the `shipping` user. The MySQL database *must* have this specific user created, and the credentials (`DB_USER`, `DB_PASS`) must be provided as environment variables in the `.service` file.
*   **Schema & Data Mismatches:** Simply loading a schema file is not enough. We discovered through debugging that the application had two further requirements: a specific table name (`codes` instead of `cities`) and pre-existing master data. The multi-step database preparation process directly addresses these code-driven infrastructure requirements.

#### Verification and Health Checks

1.  **Check Final Service Status:** After starting, verify the service is running correctly.
    ```sh
    sudo systemctl status shipping
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Review Application Logs:** `journalctl` is your most important tool here. It will show Java stack traces if something is wrong.
    ```sh
    sudo journalctl -u shipping -e
    ```
    *   **Expected Outcome:** Clean startup logs showing a successful connection to the MySQL database, with no table or database-related errors.

3.  **End-to-End Test:** The ultimate verification is to use the Roboshop website to get a shipping quote for items in the cart. This tests the full chain from Frontend -> Cart -> Shipping -> MySQL.

#### Troubleshooting Guide

| Problem                                  | Possible Cause & Solution                                                                                                                                                                                                                                              |
|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `no main manifest attribute` in logs.     | The `ExecStart` path in `/etc/systemd/system/shipping.service` is pointing to the wrong file. It **must** point to the JAR file that Maven generated in the `/target/` directory.                                                                                            |
| `Access Denied for user 'shipping'@...`  | The `shipping` user was either not created in the MySQL database, or the `DB_USER`/`DB_PASS` environment variables in the `.service` file are incorrect. Verify both.                                                                                                   |
| `Unknown database 'cities'` or `Table ... doesn't exist` | The database schema preparation (Step 6) was missed or done incorrectly. Ensure you have loaded the `schema.sql`, performed the `RENAME TABLE` operation, and loaded the `master-data.sql` *before* starting the service for the final time. |