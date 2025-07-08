---

### Component Deployment: Frontend (Web Server)

This section details the deployment of the Frontend service. This component is the public face of the application, responsible for serving the user interface and routing all API requests to the appropriate backend services. It is the only component in the architecture directly exposed to public internet traffic.

#### Deployment Steps

1.  **Install Nginx Web Server**
    Nginx is a high-performance web server that will serve our static HTML/CSS/JS content and act as a reverse proxy.
    ```sh
    sudo yum install nginx -y
    ```

2.  **Start and Enable Nginx**
    We start the Nginx service and enable it to ensure it launches automatically on system boot.
    ```sh
    sudo systemctl enable nginx
    sudo systemctl start nginx
    ```

3.  **Deploy Roboshop Frontend Content**
    The default Nginx content is removed and replaced with the custom Roboshop user interface files.
    *   **Action 1: Remove default content.**
        ```sh
        sudo rm -rf /usr/share/nginx/html/*
        ```
    *   **Action 2: Download and extract Roboshop web content.**
        ```sh
        curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
        cd /usr/share/nginx/html
        sudo unzip /tmp/web.zip
        ```

4.  **Configure Nginx Reverse Proxy**
    This is the most critical step. A configuration file is created to tell Nginx how to route API requests. Each `location` block directs traffic intended for a specific microservice to that service's private IP address.
    *   **Action:** Create the file `/etc/nginx/default.d/roboshop.conf`.
    *   **IMPORTANT:** The following content is a template. You **must** replace all instances of `localhost` with the correct private IP addresses of your backend microservice servers.
        ```nginx
        proxy_http_version 1.1;
        
        # This rule serves static images with a short expiry time.
        location /images/ {
          expires 5s;
          root   /usr/share/nginx/html;
          try_files $uri /images/placeholder.jpg;
        }

        # The following rules proxy API requests to the backend services.
        # ---- REPLACE ALL IPs BELOW ----
        location /api/catalogue/ { proxy_pass http://<CATALOGUE-IP>:8080/; }
        location /api/user/      { proxy_pass http://<USER-IP>:8080/; }
        location /api/cart/      { proxy_pass http://<CART-IP>:8080/; }
        location /api/shipping/  { proxy_pass http://<SHIPPING-IP>:8080/; }
        location /api/payment/   { proxy_pass http://<PAYMENT-IP>:8080/; }
        
        # Nginx health status endpoint
        location /health {
          stub_status on;
          access_log off;
        }
        ```

5.  **Restart Nginx to Apply Configuration**
    A restart is required for Nginx to load the new `roboshop.conf` reverse proxy configuration.
    ```sh
    sudo systemctl restart nginx
    ```

#### Configuration Deep Dive: The Reverse Proxy
The `roboshop.conf` file turns Nginx from a simple web server into an intelligent gateway.
*   **How it Works:** When Nginx receives a request like `http://my-domain.com/api/cart/123`, it matches the `location /api/cart/` block. Instead of looking for a local file, it opens a new connection to the private IP of the Cart server (defined in `proxy_pass`) and forwards the request. When the Cart server responds, Nginx returns that response to the original user's browser.
*   **Architectural Benefits:**
    *   **Security:** Backend services are not directly exposed to the internet. The Nginx server is the only public-facing component, dramatically reducing the system's attack surface.
    *   **Centralization:** All API traffic passes through one point, making it easy to manage logging, apply security rules, or handle SSL termination.
    *   **Decoupling:** The frontend web application is simplified. It sends all API requests to its own origin, and Nginx handles the complex routing behind the scenes.

#### Verification and Health Checks

1.  **Check Service Status:** Verify the `nginx` process is running correctly.
    ```sh
    sudo systemctl status nginx
    ```
    *   **Expected Outcome:** A green `active (running)` status.

2.  **Validate Nginx Configuration Syntax:** This is a crucial step before restarting. It checks your `.conf` files for typos.
    ```sh
    sudo nginx -t
    ```
    *   **Expected Outcome:** A message indicating the syntax is `ok` and the test is `successful`. If it fails, it will point you to the file and line with the error.

3.  **Perform End-to-End Test:**
    *   **Action:** Open a web browser and navigate to the public IP address of your Nginx server.
    *   **Expected Outcome:** The Roboshop homepage should load correctly. Click on products, add them to the cart, and navigate between pages. If all these actions work, it confirms your reverse proxy is correctly routing traffic to all backend services.

#### Troubleshooting Guide

| Problem                                  | Possible Cause & Solution                                                                                                                                                                                                                                                                  |
|------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Page shows a **502 Bad Gateway** error.    | This is the classic reverse proxy error. It means Nginx could not get a valid response from a backend service (e.g., `catalogue`). <br> **1. Backend Service is Down:** SSH to the backend server (e.g., Catalogue) and run `systemctl status catalogue` to see if it's failed. <br> **2. Wrong IP in `roboshop.conf`:** Double-check the `proxy_pass` IP for that location. <br> **3. Security Group Firewall:** The Nginx server's security group must be allowed to make outbound connections, and the backend server's security group must allow inbound traffic from the Nginx server on port `8080`. |
| "Welcome to Nginx" page is showing.      | **1. Content Not Deployed:** The `rm` or `unzip` commands in Step 3 failed. Check that the contents of `/usr/share/nginx/html` are the Roboshop files. <br> **2. `roboshop.conf` Not Loaded:** Ensure the file exists in `/etc/nginx/default.d/`.                                                  |
| Roboshop page loads but products/images are missing. | This means static content is working, but API calls are failing. This almost always points to a problem with the reverse proxy configuration. Use the developer tools in your browser (Network tab) to see which API calls are failing (they will likely show a 502 error), then use the "502 Bad Gateway" troubleshooting steps. |