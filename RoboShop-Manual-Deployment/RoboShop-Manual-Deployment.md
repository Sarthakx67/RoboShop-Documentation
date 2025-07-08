# RoboShop: End-to-End Manual Deployment Runbook

## Introduction
This document provides a comprehensive, step-by-step guide for the manual deployment of the RoboShop microservices application onto AWS EC2 instances running a RHEL-based Linux distribution.

---

## Deployment Order
The services will be deployed in a logical order, starting with the core data services (Persistence Tier), followed by the backend services (Application Tier), and finally the user-facing service (Presentation Tier).

1.  **Persistence Tier:** MongoDB, Redis, MySQL, RabbitMQ
2.  **Application Tier:** Catalogue, User, Cart, Shipping, Payment
3.  **Presentation Tier:** Frontend (Nginx)

---
## 1. Persistence Tier Deployment

### 1.1. MongoDB Server
Deploys the NoSQL database used for product catalog data.

**Deployment Steps:**
1.  Configure the YUM repository for MongoDB by creating `/etc/yum.repos.d/mongo.repo`:
    ```ini
    [mongodb-org-4.2]
    name=MongoDB Repository
    baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
    gpgcheck=0
    enabled=1
    ```
2.  Install the MongoDB package:
    ```sh
    sudo dnf install mongodb-org -y
    ```
3.  Update the network configuration in `/etc/mongod.conf` to allow remote connections:
    *   Change `bindIp: 127.0.0.1` to `bindIp: 0.0.0.0`
4.  Start and enable the `mongod` service:
    ```sh
    sudo systemctl enable mongod
    sudo systemctl start mongod
    ```
**Verification:**
```sh
sudo systemctl status mongod
# Check for a successful connection response
mongo --eval 'db.stats()'
```

### 1.2. Redis Server
Deploys the in-memory cache used for user session data.

**Deployment Steps:**
1.  Install the Remi repository and enable the Redis 6.2 module stream:
    ```sh
    sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
    sudo dnf module enable redis:remi-6.2 -y
    ```
2.  Install the Redis package:
    ```sh
    sudo dnf install redis -y
    ```
3.  Update the network configuration in `/etc/redis.conf` or `/etc/redis/redis.conf` to allow remote connections:
    *   Change `bind 127.0.0.1` to `bind 0.0.0.0`
4.  Start and enable the Redis service:
    ```sh
    sudo systemctl enable redis
    sudo systemctl start redis
    ```
**Verification:**
```sh
sudo systemctl status redis
# Server should respond with PONG
redis-cli ping
```

### 1.3. MySQL Server
Deploys the SQL database for transactional user and order data.

**Deployment Steps:**
1.  Disable the default MySQL module and enable MySQL 8.0:
    ```sh
    sudo dnf module disable mysql -y
    sudo dnf install mysql-community-server -y
    ```
2.  Start and enable the `mysqld` service:
    ```sh
    sudo systemctl enable mysqld
    sudo systemctl start mysqld
    ```
3.  Run the security installation script to set the root password and secure the installation:
    ```sh
    sudo mysql_secure_installation
    ```
4.  Login to MySQL as root and load the schema required by the application.
    ```sql
    mysql -u root -p
    mysql> source /path/to/schema.sql;
    ```
**Verification:**
```sh
sudo systemctl status mysqld
# Attempt to login with the new root password
mysql -u root -p
```

### 1.4. RabbitMQ Server
Deploys the message broker for asynchronous communication.

**Deployment Steps:**
1.  Install the Erlang repository and its dependency, Socat:
    ```sh
    curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash
    sudo dnf install socat -y
    ```
2.  Install the RabbitMQ server:
    ```sh
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
    sudo dnf install rabbitmq-server -y
    ```
3.  Start and enable the `rabbitmq-server` service:
    ```sh
    sudo systemctl enable rabbitmq-server
    sudo systemctl start rabbitmq-server
    ```
4.  Create the application user and set permissions:
    ```sh
    # Replace <password> with a strong secret
    sudo rabbitmqctl add_user roboshop <password>
    sudo rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
    ```
**Verification:**
```sh
sudo systemctl status rabbitmq-server
sudo rabbitmqctl list_users
```

---

## 2. Application Tier Deployment

*(This process is repeated for each application microservice: **Catalogue, User, Cart, Shipping, Payment**)*

### Example: 2.1. Catalogue Service (NodeJS)
1.  **Install Runtime:** Install NodeJS LTS.
    ```sh
    curl -sL https://rpm.nodesource.com/setup_lts.x | sudo bash
    sudo dnf install nodejs -y
    ```
2.  **Create App User & Directory:**
    ```sh
    sudo useradd roboshop
    sudo mkdir -p /app
    ```
3.  **Download and Unpack Artifact:**
    ```sh
    curl -L -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
    cd /app
    sudo unzip -o /tmp/catalogue.zip
    ```
4.  **Install Dependencies:**
    ```sh
    cd /app
    sudo npm install
    ```
5.  **Configure Systemd Service:** Create `/etc/systemd/system/catalogue.service`. Note the environment variables for dependencies.
    ```ini
    [Unit]
    Description=Catalogue Service
    [Service]
    User=roboshop
    Environment=MONGO=true
    Environment=MONGO_URL="mongodb://<MONGODB_IP_OR_DNS>:27017/catalogue"
    ExecStart=/bin/node /app/server.js
    [Install]
    WantedBy=multi-user.target
    ```
6.  **Start and Enable Service:**
    ```sh
    sudo systemctl daemon-reload
    sudo systemctl enable catalogue
    sudo systemctl start catalogue
    ```
7.  **Load Schema:**
    ```sh
    sudo dnf install mongodb-org-shell -y
    mongo --host <MONGODB_IP_OR_DNS> < /app/schema/catalogue.js
    ```
**Verification:**
```sh
sudo systemctl status catalogue
# Check for a successful startup log and connection to DB
sudo journalctl -u catalogue -e
```

---

## 3. Presentation Tier Deployment

### 3.1. Frontend (Nginx)
Deploys the web server that serves static content and acts as a reverse proxy.

**Deployment Steps:**
1.  Install the Nginx package:
    ```sh
    sudo dnf install nginx -y
    ```
2.  Remove the default content:
    ```sh
    sudo rm -rf /usr/share/nginx/html/*
    ```
3.  Download and unpack the frontend application content:
    ```sh
    curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
    cd /usr/share/nginx/html
    sudo unzip /tmp/web.zip
    ```
4.  **Configure Reverse Proxy:** Create `/etc/nginx/default.d/roboshop.conf` with the proxy configurations. **This is the most critical step.**
    ```nginx
    proxy_http_version 1.1;

    location /api/catalogue/ { proxy_pass http://<CATALOGUE_IP_OR_DNS>:8080/; }
    location /api/user/ { proxy_pass http://<USER_IP_OR_DNS>:8080/; }
    location /api/cart/ { proxy_pass http://<CART_IP_OR_DNS>:8080/; }
    location /api/shipping/ { proxy_pass http://<SHIPPING_IP_OR_DNS>:8080/; }
    location /api/payment/ { proxy_pass http://<PAYMENT_IP_OR_DNS>:8080/; }

    location /images/ {
      expires 5s;
      root   /usr/share/nginx/html;
      try_files $uri /images/placeholder.jpg;
    }
    location /health {
      stub_status on;
      access_log off;
    }
    ```
5.  Start and enable the `nginx` service:
    ```sh
    sudo systemctl enable nginx
    sudo systemctl start nginx
    ```

**Configuration Deep Dive:** The `proxy_pass` directives are the core of the reverse proxy. They instruct Nginx to forward any request matching a specific path (e.g., `/api/catalogue/`) to the internal IP address of the corresponding backend microservice. This is how the tiers are connected securely.

**Verification:**
```sh
# Check that the config file has no syntax errors
sudo nginx -t
# Check the status
sudo systemctl status nginx
```

---
## Final System Verification
After all services are deployed, access the public IP address or domain name of your **Frontend** instance in a web browser. The RoboShop application should load. Test functionality by adding items to the cart, creating a user, and checking out to ensure all backend services are being proxied correctly.