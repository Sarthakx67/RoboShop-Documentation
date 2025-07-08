---

### Component Deployment: RabbitMQ (Persistence Tier)

This section covers the deployment of RabbitMQ. As a message broker, RabbitMQ is a critical component for enabling asynchronous communication between microservices, which improves the overall resilience and scalability of the application.

#### Deployment Steps

1.  **Install Erlang Repository and Prerequisite**
    RabbitMQ is written in the Erlang programming language, so Erlang must be installed first. We use a vendor-provided script to configure the required `yum` repository.
    ```sh
    curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash
    ```

2.  **Install RabbitMQ Server Repository**
    Similarly, we use another script to configure the repository for the RabbitMQ server itself.
    ```sh
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
    ```

3.  **Install RabbitMQ Server**
    With the repositories for both Erlang and RabbitMQ configured, we can now install the RabbitMQ server package.
    ```sh
    sudo yum install rabbitmq-server -y
    ```

4.  **Start and Enable the Service**
    The `rabbitmq-server` is started and enabled to ensure it launches automatically on system boot.
    ```sh
    sudo systemctl enable rabbitmq-server
    sudo systemctl start rabbitmq-server
    ```

5.  **Create Application User and Set Permissions**
    For security reasons, RabbitMQ's default `guest` user is only permitted to connect from `localhost`. Therefore, we must create a dedicated user for our applications to connect remotely.
    *   **Action:** Create the `roboshop` user and grant it full permissions within the default virtual host (`/`).
        ```sh
        # Create the user with a password
        sudo rabbitmqctl add_user roboshop roboshop123

        # Set permissions for the user
        sudo rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
        ```

#### Configuration Deep Dive: User and Permissions
The security model of RabbitMQ is a key concept for production readiness.
*   **The `guest` user:** This default user is explicitly designed for local development and management, not remote application connections. Exposing it to the network is a major security risk.
*   **`rabbitmqctl set_permissions`:** This command is how you grant rights to a user. The syntax `set_permissions -p <vhost> <user> <conf> <write> <read>` breaks down as:
    *   `-p /`: Specifies the "virtual host" (a logical grouping of queues/exchanges). `/` is the default.
    *   `roboshop`: The user being granted permissions.
    *   `".*"` (Configure): A regular expression allowing the user to configure any resource.
    *   `".*"` (Write): A regular expression allowing the user to write to any resource.
    *   `".*"` (Read): A regular expression allowing the user to read from any resource.
    In essence, this command gives the `roboshop` user full administrative-level access within the default virtual host.

#### Verification and Health Checks

1.  **Check Service Status:** Verify the RabbitMQ service is running correctly.
    ```sh
    sudo systemctl status rabbitmq-server
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Check RabbitMQ Cluster Status:** Use the `rabbitmqctl` tool for a more specific health check.
    ```sh
    sudo rabbitmqctl status
    ```
    *   **Expected Outcome:** A detailed status report of the running broker, including listeners, memory usage, etc. No errors should be present.

3.  **List Users:** Verify that the new `roboshop` user was created successfully.
    ```sh
    sudo rabbitmqctl list_users
    ```
    *   **Expected Outcome:** A table showing at least two users: `guest` and `roboshop`.

#### Troubleshooting Guide

| Problem                                  | Possible Cause & Solution                                                                                                                                                                                                                                                          |
|------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `rabbitmq-server` fails to start.      | **1. Erlang Not Installed:** The Erlang prerequisite installation failed. Verify Erlang is installed (`erl -version`). <br> **2. Hostname Resolution:** A common RabbitMQ issue. Ensure the server's hostname can be resolved correctly (e.g., it is present in `/etc/hosts`). Check logs at `/var/log/rabbitmq/`. |
| Application cannot connect or gets "Access Refused". | **1. Wrong Credentials:** The application is using an incorrect username or password. <br> **2. AWS Security Group:** The RabbitMQ server's Security Group is blocking traffic. Ensure you have an inbound rule allowing traffic on port `5672` (the standard AMQP port) from the application server's security group. <br> **3. Permissions Not Set:** The `rabbitmqctl set_permissions` command was missed, so the `roboshop` user has no rights. |
| User created but app still gets permission errors. | The user might have been created but the permissions were not set correctly. Rerun the `sudo rabbitmqctl set_permissions ...` command and verify the user's rights with `sudo rabbitmqctl list_user_permissions roboshop`. |