# RoboShop Deployment & Automation

This repository provides a comprehensive toolkit for deploying the RoboShop microservices application on AWS. It contains three distinct deployment methods, each housed in its own directory, demonstrating a progression from foundational manual procedures to production-grade, declarative automation.

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

## Repository Contents: Three Deployment Methods

This repository is structured into three primary directories, each offering a complete and standalone method for deploying the application.

### 1. `/docs` — Manual Deployment Runbooks
This directory contains the foundational, step-by-step documentation for manually deploying and configuring every RoboShop service from a base operating system. It's designed to provide a deep, fundamental understanding of the entire stack.
*   **Methodology:** Procedural, command-by-command instructions.
*   **Use Case:** Essential for learning the intricacies of each component, for training, or for troubleshooting.
*   **[Browse Manual Deployment Documentation →](./docs/)**

### 2. `/scripts` — Scripted Automation with Bash
This directory contains a full set of Bash scripts that automate the manual procedures documented in `/docs`. Each script is designed for repeatability and basic error handling.
*   **Methodology:** Procedural automation.
*   **Use Case:** For quickly deploying individual components or for environments where a simple scripting solution is preferred over a full configuration management tool.
*   **[Browse Automation Scripts →](./scripts/)**

### 3. `/ansible` — Declarative Automation with Ansible
This directory represents the most advanced, production-grade deployment method. It uses Ansible to define the entire application stack in a declarative, idempotent, and reusable way, utilizing roles and templates for maximum efficiency.
*   **Methodology:** Declarative configuration management.
*   **Use Case:** Recommended for deploying the entire application stack reliably and consistently across any environment.
*   **[Browse Ansible Engine →](./ansible/)**

---

## System Architecture

All three deployment methods result in the same secure, three-tier architecture illustrated below. All backend and database components are isolated in private network subnets, with Nginx serving as the single, fortified public entry point.

![RoboShop Architecture Diagram](./assets/roboshop-architecture.png)

---

## Recommended Deployment Method: Ansible

For a full, reliable deployment, using the Ansible engine is the recommended approach.

### Key Features of the Ansible Implementation:
*   **Modular & Reusable:** The logic for each component (`mongodb`, `catalogue`, etc.) is encapsulated in its own **role**, making the system easy to maintain and extend.
*   **Dynamic Configuration:** Jinja2 templates (`*.j2`) are used to generate server-specific configuration files on the fly, eliminating hardcoded values and increasing flexibility.
*   **Centralized Orchestration:** The master playbook, [`site.yml`](./ansible/site.yml), acts as the single entry point to orchestrate the entire deployment across all servers defined in the [`inventory.ini`](./ansible/inventory.ini).

### How to Execute the Ansible Deployment:

1.  **Configure:** Update the `ansible/inventory.ini` file with the IP addresses of your provisioned EC2 instances.
2.  **Execute:** Navigate to the `/ansible` directory and run the master playbook:
    ```bash
    # This single command configures the entire application stack.
    ansible-playbook -i inventory.ini site.yml
    ```
---

## Future Development

While the Ansible implementation provides robust configuration management, the infrastructure itself is still provisioned manually. The next logical extension of this project is:

*   **Infrastructure as Code (IaC):** Create a new `/terraform` directory and write Terraform code to fully automate the provisioning of all necessary AWS resources (VPC, Subnets, EC2 Instances, Security Groups, etc.), making the entire environment reproducible from code.