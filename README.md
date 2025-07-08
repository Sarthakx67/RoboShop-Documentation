<!-- 
=================================================================================
!!! HELLO! THIS IS YOUR README TEMPLATE !!!
Fill in the sections below. The comments like this one will not be visible in the
final rendered README.
=================================================================================
-->

<h1 align="center">RoboShop: A DevOps End-to-End Deployment Project</h1>
<p align="center">
  <em>A comprehensive portfolio project demonstrating the manual and automated deployment of a polyglot microservices e-commerce application onto AWS.</em>
</p>

<!-- Badges are a great way to show off! Go to shields.io to create your own. -->
<p align="center">
  <img src="https://img.shields.io/badge/Project%20Status-Complete-green.svg" alt="Project Status">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS">
  <img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white" alt="Nginx">
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL">
  <img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white" alt="MongoDB">
  <img src="https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white" alt="Java">
  <img src="https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white" alt="Go">
</p>

---

## 1. Project Overview

This project is a hands-on implementation of deploying a full-stack, microservices-based e-commerce application named **RoboShop**. The primary goal is to demonstrate a deep, practical understanding of core DevOps principles, including infrastructure setup, configuration management, service deployment, and inter-service communication in a cloud environment. The project is documented in two main phases: a meticulous **Manual Deployment** and a subsequent **Automated Deployment**.

## 2. Live Demo

<!--
!!! ACTION ITEM !!!
Record a short GIF of you using the application!
1. Start recording your screen (Use a tool like LICEcap, Giphy Capture, or Kap).
2. Browse your running application: open the homepage, click a product, add it to the cart.
3. Save the recording as a GIF and place it in a 'docs/gifs' folder in your repository.
4. Replace the link below.
-->

![RoboShop Live Demo](docs/gifs/roboshop-demo.gif)

## 3. Architecture

The application is built on a classic, robust three-tier architecture, physically deployed across multiple Amazon EC2 instances within a custom VPC. This design enhances security by isolating the application and persistence tiers from direct public access.

<!--
!!! ACTION ITEM !!!
Create your architecture diagram!
1. Use a free tool like app.diagrams.net or Lucidchart.
2. Export it as a .png or .svg file and place it in a 'docs/diagrams' folder.
3. Replace the link below.
-->

![RoboShop Architecture Diagram](docs/diagrams/roboshop-architecture.png)

## 4. Key Features & Technologies

### Application Features
- **User Authentication:** Sign up, log in, and session management.
- **Product Catalog:** View and search for products.
- **Shopping Cart:** Add, update, and remove items.
- **Payment & Shipping:** Simulate payment processing and order dispatch.

### Technology Stack
- **Cloud Provider:** `Amazon Web Services (AWS)`
- **Web Server & Reverse Proxy:** `Nginx`
- **Application Runtimes:** `NodeJS`, `Java`, `Python`, `GoLang`
- **Databases:** `MySQL 5.7` (Relational), `MongoDB` (NoSQL), `Redis` (In-Memory Cache)
- **Messaging Queue:** `RabbitMQ`
- **Build Tools:** `Maven` (for Java), `Go Modules` (for Go)
- **Operating System:** `CentOS / RHEL 8`

## 5. Project Structure

A clean and organized repository structure.

```roboshop-project/
├── docs/
│   ├── diagrams/
│   │   └── roboshop-architecture.png
│   └── gifs/
│       └── roboshop-demo.gif
├── MANUAL_DEPLOYMENT.md        <-- You Are Here
├── automated-deployment/       <-- (Optional Future Section)
│   ├── ansible-playbooks/
│   └── terraform-manifests/
└── README.md
```

## 6. How To Use This Documentation

This project contains highly detailed deployment documentation. The best place to start is with the manual deployment guide.

➡️ **[View the Complete Manual Deployment Guide](./MANUAL_DEPLOYMENT.md)**

This guide contains the step-by-step commands and configurations for every single service, from the network setup to the final application verification.

## 7. What I Learned

This project was a deep dive into practical, real-world deployment challenges. Key learnings include:
- **Robust Infrastructure Setup:** Mastered the process of configuring a secure AWS VPC, subnets, and security groups from scratch.
- **Solving Dependency Conflicts:** Successfully troubleshooted and resolved OS-level package conflicts (e.g., `mariadb` vs `mysql`) and module filtering issues in CentOS 8.
- **Schema and Data Orchestration:** Understood that application functionality is deeply tied to correct database schema and initial data. The multi-step setup for the Shipping service (load schema -> rename table -> load data) was a critical lesson in state management.
- **The Power of the Reverse Proxy:** Gained a deep appreciation for Nginx as a gateway for controlling access, routing traffic, and simplifying a complex microservices architecture.

## 8. Future Improvements

This project serves as an excellent baseline. The next logical steps are to automate this entire process:
- **[ ] Infrastructure as Code (IaC):** Use `Terraform` to codify the creation of all AWS resources (VPC, EC2 instances, Security Groups, etc.).
- **[ ] Configuration Management:** Use `Ansible` to automate all the server-side steps documented in the manual guide (installing packages, configuring services, etc.).
- **[ ] CI/CD Pipeline:** Create a `Jenkins` or `GitHub Actions` pipeline that automatically triggers the Terraform and Ansible automation when code is pushed to this repository.

<!-- 
This section is optional, but professional!
-->
---
<p align="center">
  Find me on <a href="[Your LinkedIn URL]">LinkedIn</a> or check out my other projects on <a href="[Your GitHub Profile URL]">GitHub</a>.
</p>