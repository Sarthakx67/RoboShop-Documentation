# RoboShop Deployment & Automation Toolkit

This repository provides a comprehensive toolkit for deploying the RoboShop microservices application on AWS. It contains three distinct, complete deployment methods, demonstrating a progression from foundational manual procedures to production-grade, declarative automation.

## Technology Showcase
![Ansible](https://img.shields.io/badge/Ansible-1A1924?style=for-the-badge&logo=ansible&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Shell Script](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DD0031?style=for-the-badge&logo=redis&logoColor=white)

---

## Architectural Overview

The application is deployed using a secure, three-tier architecture that separates concerns and minimizes attack surface by isolating backend components.

![RoboShop Architecture Diagram](./assets/roboshop-architecture.png)

---

## Repository Contents

This repository is structured into three primary directories, each offering a complete and standalone method for deploying the application.

- **[`/docs`](./docs/) — Manual Deployment Runbooks**
  - Contains foundational, step-by-step documentation for manually deploying and configuring every RoboShop service. This is ideal for understanding the core dependencies of the system.

- **[`/scripts`](./scripts/) — Scripted Automation with Bash**
  - Provides a full set of Bash scripts that automate the manual procedures documented in `/docs`. This demonstrates repeatable, procedural automation.

- **[`/ansible`](./ansible/) — Declarative Automation with Ansible**
  - The most advanced deployment method. This section uses Ansible to define the entire application stack in a declarative, idempotent, and reusable way, utilizing roles and templates for production-grade configuration management.

---
### **Presentation Tier (Web)**
*   **Role:** Serves as the public-facing entry point for the application.
*   **Technology:** Nginx is used to serve the static frontend content (HTML, CSS, JS) and to act as a **reverse proxy**. It securely routes API requests from users to the appropriate internal microservices.

### **Application Tier (App)**
*   **Role:** Contains the core business logic of the application, composed of multiple, independent microservices.
*   **Key Principle:** This entire tier is deployed in a private network, inaccessible from the internet. All traffic must be proxied through the Web Tier, creating a secure boundary.
*   **Technology:** The services are polyglot (NodeJS, Java, etc.) and run with their own embedded servers.

### **Persistence Tier (DB)**
*   **Role:** Manages all data storage, caching, and messaging for the application.
*   **Technology:** This tier utilizes the best tool for each job:
    *   **MongoDB:** Stores the unstructured product catalog.
    *   **MySQL:** Manages transactional data like user accounts and orders.
    *   **Redis:** Provides high-speed, in-memory caching for user sessions.
    *   **RabbitMQ:** Decouples services through asynchronous message passing.

---

## About This Project
This repository is a portfolio piece designed to showcase hands-on proficiency in cloud deployment and automation. It demonstrates a clear progression from manual, procedural tasks to fully declarative, production-ready configuration management.