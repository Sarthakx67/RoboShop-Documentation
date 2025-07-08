### 4.2. Catalogue Service Deployment (Application Tier)

This service is responsible for providing the list of all products to the frontend user interface. It is a NodeJS-based microservice that queries the MongoDB database.

*   **Component:** Catalogue
*   **Runtime:** NodeJS
*   **Purpose:** Serves as the API for product information.

---

#### **Step 1: Install NodeJS Runtime**

NodeJS is the environment required to run the JavaScript-based Catalogue service. The official NodeSource repository provides the most up-to-date and stable Long-Term Support (LTS) version.

*   **Action:** Download and run the NodeSource setup script, then install NodeJS.

    ```sh
    # This script configures the YUM repository for NodeJS LTS
    curl -sL https://rpm.nodesource.com/setup_lts.x | sudo bash

    # Install NodeJS from the newly configured repository
    sudo yum install nodejs -y
    ```

#### **Step 2: Create an Application User and Directory**

To follow security best practices, the application should not run as the `root` user. A dedicated, non-login user is created to own and run the application files. A standardized directory is also created to store the application code.

*   **Action:** Create the user and directory.

    ```sh
    # Create the 'roboshop' user. This is a system user with no login shell.
    sudo useradd roboshop

    # Create the application directory '/app' where the code will reside.
    sudo mkdir /app
    ```

#### **Step 3: Download and Deploy Application Artifact**

The application code, which has been pre-packaged into a `.zip` file (an "artifact"), is downloaded from a central repository and unzipped into the application directory.

*   **Action:** Download and extract the code.

    ```sh
    # Download the zipped catalogue code to the temporary directory
    curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

    # Navigate to the application directory
    cd /app

    # Unzip the artifact
    sudo unzip /tmp/catalogue.zip
    ```

#### **Step 4: Install Application Dependencies**

NodeJS projects use `npm` (Node Package Manager) to install required third-party libraries, which are defined in the `package.json` file included with the code.

*   **Action:** Install the NodeJS dependencies.

    ```sh
    # Change directory to where the package.json file is located
    cd /app

    # This command reads package.json and installs the required libraries
    sudo npm install
    ```

#### **Step 5: Configure the Systemd Service**

A `systemd` service file is created to manage the application process. This allows the operating system to automatically start, stop, and restart the service, ensuring it runs reliably in the background.

*   **Action:** Create a `.service` file for the Catalogue service.

    ```sh
    sudo vim /etc/systemd/system/catalogue.service
    ```

*   **File Content:** Paste the following configuration. **You must replace `<MONGODB-SERVER-IPADDRESS>` with the actual private IP address of your MongoDB server.**

    ```ini
    [Unit]
    Description=Catalogue Service

    [Service]
    # Run the service as the 'roboshop' user
    User=roboshop

    # Set environment variables required by the application
    Environment=MONGO=true
    Environment=MONGO_URL="mongodb://<MONGODB-SERVER-IPADDRESS>:27017/catalogue"

    # Define the command that starts the application
    ExecStart=/bin/node /app/server.js
    
    # Set a custom identifier for logging
    SyslogIdentifier=catalogue

    [Install]
    WantedBy=multi-user.target
    ```

#### **Step 6: Start the Catalogue Service**

Load the new service configuration into `systemd` and start the service.

*   **Action:** Reload the `systemd` daemon and start the service.

    ```sh
    # Reloads the systemd manager configuration
    sudo systemctl daemon-reload

    # Enable the service to start on boot
    sudo systemctl enable catalogue

    # Start the service immediately
    sudo systemctl start catalogue
    ```

#### **Step 7: Load Application Schema into MongoDB**

The application requires a predefined data structure (a schema) in the database to function. This one-time setup populates MongoDB with the initial catalogue data. To do this, we need the MongoDB client tools on this server.

*   **Action:** Install the MongoDB shell and run the schema loader script.

    ```sh
    # 1. Install only the mongo shell, not the entire database
    sudo yum install mongodb-org-shell -y

    # 2. Run the schema loader script against the MongoDB server
    #    (Replace <MONGODB-SERVER-IPADDRESS> with your DB's private IP)
    mongo --host <MONGODB-SERVER-IPADDRESS> </app/schema/catalogue.js
    ```

#### **IMPORTANT: Post-Deployment Configuration**

*   **Action Required:** For the entire application to function, the **Frontend (Nginx) server** must be updated. Its configuration file (`/etc/nginx/default.d/roboshop.conf`) contains a reverse proxy entry for the catalogue service that must be pointed to this server's IP address. This cross-component configuration is a critical final step.