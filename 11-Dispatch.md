---

### Component Deployment: Dispatch Service (Application Tier)

This section details the deployment of the Dispatch service. This microservice is written in Go (Golang) and its primary responsibility is to handle the logistics of dispatching products after a successful payment by listening for messages from RabbitMQ.

#### Deployment Steps

1.  **Install GoLang**
    The Go language compiler and toolchain are required to build the application from source. We install this using `yum`.
    ```sh
    sudo yum install golang -y
    ```

2.  **Create Application User and Directory**
    A standard `roboshop` application user and `/app` directory are created to securely own and store the application files.
    ```sh
    sudo useradd roboshop
    sudo mkdir /app
    ```

3.  **Download and Unpack Application Source**
    The Go source code for the service is downloaded as a `.zip` artifact and extracted into the `/app` directory.
    ```sh
    curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip
    cd /app
    sudo unzip /tmp/dispatch.zip
    ```

4.  **Build the Application**
    Go projects are compiled into a single executable binary. This process involves initializing a Go module, fetching dependencies, and then building the binary.
    ```sh
    cd /app
    # Initializes a go.mod file to manage dependencies
    go mod init dispatch
    # Downloads the required libraries
    go get
    # Compiles the source into an executable named 'dispatch'
    go build
    ```
    *Note: The `go build` command creates a single file named `dispatch` in the `/app` directory.*

5.  **Configure Systemd Service**
    A `systemd` service file is created to manage the compiled Dispatch executable as a background service.
    *   **Action:** Create the file `/etc/systemd/system/dispatch.service`. **Note: The RabbitMQ IP is a placeholder and must be replaced.**
        ```ini
        [Unit]
        Description=Dispatch Service

        [Service]
        User=roboshop
        Environment=AMQP_HOST=<RABBITMQ-SERVER-IP-ADDRESS>
        Environment=AMQP_USER=roboshop
        Environment=AMQP_PASS=roboshop123
        ExecStart=/app/dispatch
        SyslogIdentifier=dispatch

        [Install]
        WantedBy=multi-user.target
        ```

6.  **Start and Enable the Service**
    The `systemd` daemon is reloaded and the service is started and enabled to run on boot.
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl enable dispatch
    sudo systemctl start dispatch
    ```

#### Configuration Deep Dive: The Go Build Process
The Go language deployment model is different from the other services and offers significant advantages:
*   **Statically Linked Binary:** The `go build` command produces a single, self-contained executable file (`/app/dispatch`). Unlike Java, Python, or NodeJS, it does not require a separate runtime to be installed on the server to run (it's compiled directly into machine code).
*   **Dependency Management:** `go mod init` and `go get` handle all dependencies at build time. The final binary includes everything needed to run, making deployment very simple and reliable. `ExecStart=/app/dispatch` simply runs this compiled program directly.

#### Verification and Health Checks

1.  **Check Service Status:** Use `systemctl` to ensure the Dispatch service has started and is running correctly.
    ```sh
    sudo systemctl status dispatch
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Review Application Logs:** This is the most important verification step for a background worker. The logs will show if it successfully connected to RabbitMQ.
    ```sh
    sudo journalctl -u dispatch -e
    ```
    *   **Expected Outcome:** Messages indicating a successful AMQP connection and that the service is "waiting for messages".

#### Troubleshooting Guide

| Problem                                | Possible Cause & Solution                                                                                                                                                                                                                                                                                       |
|----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| The `go build` command fails.          | **1. Missing Dependencies:** The `go get` command may have failed due to network issues or a problem with the source repository. <br> **2. Syntax Errors:** The downloaded source code itself might have compilation errors. Check the output of `go build` for specific error messages. |
| Service fails to start or is in a crash loop. | **1. Executable Not Found:** The `ExecStart=` path in the `.service` file might be wrong, or the `go build` command failed, so `/app/dispatch` does not exist. Verify the file exists. <br> **2. Permissions Error:** Ensure the `/app/dispatch` executable has execute permissions for the `roboshop` user. |
| Logs show connection errors to RabbitMQ. | **1. Incorrect IP/Credentials:** The IP in `AMQP_HOST` or the credentials (`AMQP_USER`/`AMQP_PASS`) in `/etc/systemd/system/dispatch.service` are wrong. Verify them, run `daemon-reload`, and restart the service. <br> **2. Security Group Firewall:** The RabbitMQ server's Security Group is blocking inbound traffic on port `5672` from the Dispatch server. This is a very common cause. |