# RoboShop End-to-End Deployment on AWS

[![Project Status: In Progress](https://img.shields.io/badge/status-in_progress-yellow.svg)](https://github.com/Sarthakx67/RoboShop-Documentation/)

This repository serves as a comprehensive portfolio project, documenting the complete manual deployment of the RoboShop e-commerce application. Its primary goal is to demonstrate and solidify foundational DevOps skills, including cloud infrastructure setup, network configuration, manual service deployment, and system troubleshooting in a realistic, multi-tier environment.

---

## System Architecture

The application is deployed using a classic **Three-Tier Architecture**. This design separates concerns into distinct layers, which enhances security, simplifies maintenance, and allows each tier to be scaled independently.

The custom diagram below illustrates the flow of communication between the components as implemented in this project.

<!-- This relative path points to the image inside your 'assets' folder -->
![RoboShop Architecture Diagram](./assets/roboshop-architecture.png)

*   **Presentation Tier (Frontend):** A public-facing Nginx server that serves static content and acts as a secure reverse proxy for all backend services.
*   **Application Tier (Backend):** A set of protected microservices running in a private network, each handling specific business logic (e.g., Catalogue, User, Cart).
*   **Persistence Tier (Data):** A collection of databases, caches, and message brokers, also in a private network, to manage all application data (e.g., MongoDB, Redis, MySQL).

---

## Technology Stack

This project utilizes a wide range of industry-standard technologies to mirror a real-world polyglot environment.

| Category                  | Technologies                                |
|---------------------------|---------------------------------------------|
| **Cloud Provider**        | Amazon Web Services (AWS)                   |
| **Compute & Networking**  | EC2, VPC, Subnets, Security Groups, Route 53 |
| **Web Server**            | Nginx                                       |
| **Application Runtimes**  | NodeJS, Python, Java                        |
| **Databases**             | MongoDB, MySQL, Redis                       |
| **Messaging**             | RabbitMQ                                    |
| **Deployment Tools**      | Bash, `systemd`, `yum`, `npm`               |


---

## Deployment Runbooks

The complete end-to-end deployment process is documented in a modular, step-by-step format. Each file below is a detailed runbook for a specific component.

*   **Infrastructure & Setup**
    *   [01 - Frontend (Nginx)](./Manual-Deployment/01-Frontend.md)
    *   [02 - MongoDB](./Manual-Deployment/02-MongoDB.md)
    *   [03 - Catalogue Service](./Manual-Deployment/03-Catalogue.md)
    *   [04 - Redis](./Manual-Deployment04-Redis.md) <!-- Edit this to add ✔️ when you are done with the content -->
    *   [05 - User Service](./Manual-Deployment/05-User.md)
    *   [06 - Cart Service](./06-Cart.md) <!-- Placeholder for next service -->
    *   [07 - MySQL](./07-MySQL.md) <!-- Placeholder for next service -->
    *   [08 - Shipping Service](./08-Shipping.md) <!-- Placeholder for next service -->
    *   [09 - Payment Service](./09-Payment.md) <!-- Placeholder for next service -->


---

## Project Learning Objectives

Through this project, I am developing and demonstrating proficiency in:

-   [x] Cloud infrastructure design and manual provisioning on AWS.
-   [x] Configuring network security (VPCs, Public/Private Subnets, Security Groups).
-   [x] Deploying and managing Linux-based web servers and reverse proxies (Nginx).
-   [x] Manually deploying polyglot microservices (NodeJS, Python, Java).
-   [x] Setting up and managing multiple database systems (MongoDB, Redis, MySQL).
-   [x] Creating and managing systemd services to ensure application reliability.
-   [ ] Creating high-quality technical documentation for operational procedures.

---

## Future Roadmap

This manual deployment project is the foundational first phase. The subsequent phases of this project will focus on progressive automation, applying core DevOps principles.

*   **Phase 2: Automation with Bash Scripting**
    *   Convert all manual command sequences into reusable Bash scripts to make deployments repeatable.
*   **Phase 3: Configuration Management with Ansible**
    *   Develop Ansible playbooks and roles to fully automate the configuration and deployment of all application services.
*   **Phase 4: Infrastructure as Code (IaC) with Terraform**
    *   Write Terraform code to automatically provision the entire AWS infrastructure stack (VPC, EC2 instances, Security Groups, etc.).
*   **Phase 5: Continuous Integration/Continuous Deployment (CI/CD) with Jenkins**
    *   Create a Jenkins pipeline to automatically trigger the Terraform and Ansible jobs, building a complete CI/CD workflow from code commit to deployment.