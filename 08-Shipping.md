---

### Component Deployment: Shipping Service (Application Tier)

This section details the deployment of the Shipping service. This is a Java-based microservice responsible for calculating shipping costs. It depends on the MySQL database for its data and the Cart service for cart information.

#### Deployment Steps

1.  **Install Java and Maven**
    This is a Java application, so it requires a Java Development Kit (JDK) to run and Maven to build the project from source. Installing Maven conveniently handles the installation of Java as a dependency.
    ```sh
    sudo yum install maven -y
    ```

2.  **Create Application User and Directory**
    A non-login `roboshop` user is created for security, along with a standard `/app` directory for the code.
    ```sh
    sudo useradd roboshop
    sudo mkdir /app
    ```

3.  **Download and Unpack Application Source**
    The application source code is downloaded as a `.zip` artifact and extracted into the `/app` directory.
    ```sh
    curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
    cd /app
    sudo unzip /tmp/shipping.zip
    ```

4.  **Build and Package the Application**
    Using Maven, we compile the source code and package it into an executable `.jar` file. The `mvn clean package` command deletes any old builds and creates a new one.
    ```sh
    cd /app
    sudo mvn clean package
    ```

5.  **Prepare the Executable JAR**
    The `mvn` command creates the final artifact at `/app/target/shipping-1.0.jar`. For simplicity and a cleaner `systemd` file, we move this to the parent `/app` directory with a simpler name.
    ```sh
    # Move the runnable JAR to the main app directory
    mv /app/target/shipping-1.0.jar /app/shipping.jar
    ```

6.  **Configure and Start the Service**
    A `systemd` service file is created to manage the application. After it's created, we perform an initial start.
    *   **Action:** Create the file `/etc/systemd/system/shipping.service`. **Note: The IP addresses are placeholders and must be replaced.**
        ```ini
        [Unit]
        Description=Shipping Service

        [Service]
        User=roboshop
        Environment=CART_ENDPOINT=<CART-SERVER-IP-ADDRESS>:8080
        Environment=DB_HOST=<MYSQL-SERVER-IP-ADDRESS>
        ExecStart=/bin/java -jar /app/shipping.jar
        SyslogIdentifier=shipping

        [Install]
        WantedBy=multi-user.target
        ```
    *   **Action:** Load and start the service.
        ```sh
        sudo systemctl daemon-reload
        sudo systemctl enable shipping
        sudo systemctl start shipping
        ```
        *Note: The service will likely fail at this point and will need to be restarted after the database schema is loaded.*

7.  **Load Database Schema and Data**
    The service requires a specific database schema and initial data to function. We must install the MySQL client, load the schema, and then load the master data.
    ```sh
    # Install the MySQL client tools
    sudo yum install mysql -y

    # Load the schema and then the master data. Replace the IP and password.
    mysql -h <MYSQL-SERVER-IP> -uroot -pRoboShop@1 < /app/schema/shipping.sql
    ```

8.  **Restart the Service**
    Finally, we restart the Shipping service. This allows it to connect to the database, which now has the correct schema and data loaded, and start successfully.
    ```sh
    sudo systemctl restart shipping
    ```

#### Configuration Deep Dive: From Build to Runtime
This Java service deployment highlights several key real-world challenges:
*   **Build vs. Run:** Unlike the NodeJS services where code is run directly, here we have a distinct **build step** (`mvn clean package`). This compilation process produces a self-contained, executable `.jar` file, which is what `systemd` actually runs. A common failure point is pointing `ExecStart` to the wrong JAR file.
*   **Schema Dependency:** The service is tightly coupled to its database schema. The documentation explicitly shows that an initial start will likely fail, and the service **must be restarted** after the schema and data are loaded. This reflects a realistic deployment flow where infrastructure and application state must be orchestrated in the correct order.

#### Verification and Health Checks

1.  **Check Final Service Status:** After the final restart, verify the service is running correctly.
    ```sh
    sudo systemctl status shipping
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Review Application Logs:** Java applications are verbose. `journalctl` is essential for viewing stack traces and startup messages.
    ```sh
    sudo journalctl -u shipping -e
    ```
    *   **Expected Outcome:** No `Access Denied` errors for the database connection and no `Table doesn't exist` exceptions. You should see logs indicating a successful startup.

#### Troubleshooting Guide

| Problem                                  | Possible Cause & Solution                                                                                                                                                                                                                                                        |
|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `no main manifest attribute` in logs.     | **1. Wrong JAR File:** This is a classic Java error. It means the `ExecStart` directive in `shipping.service` is pointing to a JAR file that isn't executable. Ensure you are pointing to the file generated by Maven in the `/target/` directory (e.g., `/app/shipping.jar` after our `mv` command). |
| `Access Denied for user 'shipping'@...`  | **1. User Does Not Exist in MySQL:** The application is hard-coded to use the user `shipping`. You must ensure that this specific user has been created in MySQL, as documented in the MySQL deployment guide. <br> **2. Wrong Password:** An incorrect password may be configured (this would require updating the application's source code or configuration). |
| `Table '...' doesn't exist` in logs.     | **1. Schema Not Loaded:** The `.sql` schema file was not loaded into the database before the service was started. Run the `mysql -h ...` command from Step 7. <br> **2. Service Not Restarted:** The service started, failed before the schema was loaded, and was never restarted. Run `sudo systemctl restart shipping`. |