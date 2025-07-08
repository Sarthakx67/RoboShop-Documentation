# RoboShop Deployment Automation Engine

This repository contains a multi-phase project designed to automate the entire deployment of the RoboShop microservices application on AWS, culminating in a production-grade configuration management system using Ansible.

## Core Project Objectives
*   **Establish a Foundational Baseline:** By first performing and documenting a complete manual deployment.
*   **Develop Repeatable Automation:** By translating manual steps into robust, idempotent shell scripts.
*   **Achieve Declarative Configuration:** By implementing a full-fledged Ansible automation engine for a scalable and maintainable deployment.

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

<br>

## Project Artifacts Overview

This project is organized into three distinct phases, each with its own set of deliverables.

| Phase                                   | Description                                                                                                                   | Deliverables Location                             |
| :-------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------ |
| **1. Manual Documentation**             | Foundational, step-by-step guides for manually deploying each service. Essential for understanding system dependencies.        | **[Browse Docs](./docs/)**                           |
| **2. Scripted Automation**              | The first layer of automation. Robust shell scripts designed for repeatability and basic error handling.                       | **[Browse Scripts](./scripts/)**                     |
| **3. Declarative Automation**           | Production-grade automation using Ansible. Declarative, idempotent, and managed via roles for maximum reusability.          | **[Browse Ansible Engine](./ansible/)**            |

<br>

## System Architecture

The infrastructure is based on a three-tier model to ensure security and scalability, with backend services isolated from public access.

![RoboShop Architecture Diagram](./assets/roboshop-architecture.png)

<br>

## Ansible Automation Engine

The core of this project is the Ansible implementation, which is designed using industry best practices.

*   **Entrypoint:** The [`site.yml`](./ansible/site.yml) playbook is the single point of execution that orchestrates the entire deployment across all hosts.
*   **Inventory:** The [`inventory.ini`](./ansible/inventory.ini) file defines the target hosts and maps them to their respective Ansible groups.
*   **Roles:** Logic is modularized into **roles** (`mongodb`, `catalogue`, etc.), each containing its own tasks, handlers, and templates. This makes the automation clean, reusable, and easy to maintain.
*   **Templates:** Jinja2 templates (`*.j2`) are used to dynamically generate server-specific configuration files, preventing hardcoded values.

### Execution

To run the entire automation pipeline:

1.  **Configure:** Update `ansible/inventory.ini` with the IP addresses of your target EC2 instances.
2.  **Run:** From the `ansible/` directory, execute the master playbook:
    ```bash
    ansible-playbook -i inventory.ini site.yml
    ```
This command will configure the entire application stack from a base OS installation.

---

## Next Steps

This project currently culminates at Phase 3. The logical next steps to extend this automation pipeline are:

*   **Phase 4 - Infrastructure as Code:** Implement Terraform to fully automate the provisioning of the AWS resources (EC2, VPC, etc.).
*   **Phase 5 - CI/CD Pipeline:** Integrate the Terraform and Ansible jobs into a Jenkins pipeline for continuous, automated delivery.