---

### Component Deployment: Payment Service (Application Tier)

This section details the deployment of the Payment service. This is a Python-based microservice that handles all payment processing logic. It has several upstream dependencies, communicating with the User service, Cart service, and RabbitMQ.

#### Deployment Steps

1.  **Install Python and Build Tools**
    The service requires a specific Python version (3.6) and associated development tools (`gcc`, `python3-devel`) which are necessary to compile certain Python libraries.
    ```sh
    sudo yum install python36 gcc python3-devel -y
    ```

2.  **Create Application User and Directory**
    A standard `roboshop` application user and `/app` directory are created, though this service's systemd file later overrides the user setting.
    ```sh
    sudo useradd roboshop
    sudo mkdir /app
    ```

3.  **Download and Unpack Application Artifact**
    The application source code is downloaded as a `.zip` artifact from S3 and extracted into the `/app` directory.
    ```sh
    curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip
    cd /app
    sudo unzip /tmp/payment.zip
    ```

4.  **Install Python Dependencies**
    Python dependencies are listed in the `requirements.txt` file. We use `pip` (Python's package installer) to install them.
    ```sh
    cd /app
    # Note the use of pip3.6 to ensure it uses the correct Python version
    sudo pip3.6 install -r requirements.txt
    ```

5.  **Configure Systemd Service**
    A `systemd` service file is created to manage the Payment service. This service is started using `uwsgi`, a Web Server Gateway Interface (WSGI) server used for building scalable Python applications.
    *   **Action:** Create the file `/etc/systemd/system/payment.service`. **Note: All IP addresses are placeholders and must be replaced.**
        ```ini
        [Unit]
        Description=Payment Service

        [Service]
        User=root
        WorkingDirectory=/app
        Environment=CART_HOST=<CART-SERVER-IP-ADDRESS>
        Environment=CART_PORT=8080
        Environment=USER_HOST=<USER-SERVER-IP-ADDRESS>
        Environment=USER_PORT=8080
        Environment=AMQP_HOST=<RABBITMQ-SERVER-IP-ADDRESS>
        Environment=AMQP_USER=roboshop
        Environment=AMQP_PASS=roboshop123

        ExecStart=/usr/local/bin/uwsgi --ini payment.ini
        ExecStop=/bin/kill -9 $MAINPID
        SyslogIdentifier=payment

        [Install]
        WantedBy=multi-user.target
        ```

6.  **Start and Enable the Service**
    Finally, we reload the `systemd` daemon, start the service, and enable it to run on boot.
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl enable payment
    sudo systemctl start payment
    ```

#### Configuration Deep Dive: `uWSGI` and `User=root`
This service's configuration has two important points to understand:
*   **`ExecStart=/usr/local/bin/uwsgi --ini payment.ini`**: Unlike the other services that are run directly by their interpreters (`node` or `java`), this Python application is launched via a `uWSGI` server. uWSGI is a production-grade application server that interfaces between a web server (like Nginx) and a Python web application, managing processes and providing higher performance than a simple development server. It is configured via the `payment.ini` file.
*   **`User=root`**: This configuration is highly unusual and is an **anti-pattern** for security. Running a web-facing service as `root` is a significant security risk. In a real production environment, this should be changed to `User=roboshop`, and permissions on any required files or ports below 1024 would need to be adjusted. For this project, we follow the instructions, but it's critical to recognize this as a security weakness.

#### Verification and Health Checks

1.  **Check Service Status:** Verify the `payment` service is running via `systemctl`.
    ```sh
    sudo systemctl status payment
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Review Application Logs:** Use `journalctl` to inspect logs for startup messages and any errors, such as connection failures to RabbitMQ or the other services.
    ```sh
    sudo journalctl -u payment -e
    ```
    *   **Expected Outcome:** Clean startup logs showing that `uwsgi` has started workers and has connected to its upstream dependencies.

#### Troubleshooting Guide

| Problem                                | Possible Cause & Solution                                                                                                                                                                                                                                                                        |
|----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Service fails to start or goes into a crash loop. | **1. `pip install` Failed:** A common issue. One of the Python packages in `requirements.txt` may have failed to install because of missing OS-level dependencies. The installation of `gcc` and `python3-devel` is meant to prevent this, but check the `pip` command's log for errors. <br> **2. `uwsgi` Not Found:** The `uwsgi` executable might not be in `/usr/local/bin/`. `pip install` should place it there, but verify its location with `which uwsgi`. |
| Logs show connection errors (`AMQP_HOST`, etc.) | **1. Incorrect IP Addresses:** The IPs for any of the host environment variables (`CART_HOST`, `USER_HOST`, `AMQP_HOST`) are wrong in the `.service` file. Correct them, run `daemon-reload`, and restart the service. <br> **2. Security Group Firewall:** The #1 cause for connection timeouts. Ensure the Security Groups for the Cart, User, and RabbitMQ servers allow inbound traffic on their respective ports from this Payment server. |
| The application starts but payments fail.      | This indicates a logic error or a misconfiguration with RabbitMQ permissions. Ensure the `roboshop` user was created in RabbitMQ with the correct password (`roboshop123`) and has full permissions.                                                                               |