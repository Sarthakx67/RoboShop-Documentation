# RoboShop Deployment Engine: A Multi-Phase Automation Project

This repository documents my initiative to engineer a complete deployment solution for the RoboShop microservices application on AWS. The project was executed in three distinct, progressive phases, moving from a foundational manual setup to a production-grade, declarative automation engine using Ansible.

## Project Thesis
The core philosophy of this project was to master the deployment process through progressive automation. By starting with a meticulous manual build, I developed the deep system understanding required to build meaningful, robust automation—first with procedural shell scripts, and culminating in a declarative, idempotent system with Ansible. This repository is the result of that engineering effort.

## Core Technologies
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

## Project Deliverables Analysis
This project is structured into three phases, each yielding a specific set of artifacts.

| Phase                                   | Artifact Description                                                                                                                   | Key Characteristics                                        |
| :-------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------- |
| **1. Manual Documentation**             | Foundational, step-by-step guides for manually deploying each service, located in [`/docs`](./docs/). Essential for understanding system dependencies.        | **Procedural, Foundational, Detailed**                     |
| **2. Scripted Automation**              | The first layer of automation. These procedural shell scripts, found in [`/scripts`](./scripts/), automate the manual steps for repeatability.                       | **Repeatable, Procedural, Foundational Automation**        |
| **3. Declarative Automation**           | **(Project Centerpiece)** A production-grade Ansible engine located in [`/ansible`](./ansible/). This declaratively defines the desired state of the entire application stack.          | **Declarative, Idempotent, Modular, Reusable**             |

<br>

## System Architecture
The infrastructure is a security-focused, three-tier architecture. All backend services are isolated in private network subnets with no direct internet access. Nginx serves as the single, fortified entry point.

![RoboShop Architecture Diagram](./assets/roboshop-architecture.png)

<br>

## Ansible Automation Engine: Technical Deep Dive
The Ansible implementation is the core technical achievement of this project and is designed using industry best practices.

*   **Declarative & Idempotent:** Playbooks define the *desired state* of the system, not just a series of commands. They can be run multiple times with the same outcome.
*   **Modular Architecture via Roles:** Logic is cleanly separated into reusable **roles** for each component (e.g., `mongodb`, `catalogue`). This makes the system maintainable and scalable.
*   **Dynamic Configuration with Templates:** Jinja2 templates (`*.j2`) are used extensively to generate dynamic server configuration files. This avoids hardcoding values and allows for flexible deployments based on variables.
*   **Centralized Orchestration:** The master playbook, [`site.yml`](./ansible/site.yml), orchestrates the entire deployment, applying the correct roles to host groups defined in the [`inventory.ini`](./ansible/inventory.ini`) file.

### How to Execute the Ansible Engine
1.  **Configure Inventory:** Populate `ansible/inventory.ini` with the IP addresses of your target EC2 instances.
2.  **Execute Playbook:** From within the `ansible/` directory, run the master playbook:
    ```bash
    # This single command configures the entire application stack.
    ansible-playbook -i inventory.ini site.yml
    ```
---

## Project Next Steps
This project currently culminates at Phase 3. The logical evolution is to automate the infrastructure layer itself:

*   **Phase 4 - Infrastructure as Code:** Implement Terraform to programmatically provision all AWS resources (EC2 instances, VPC, Security Groups), making the entire environment reproducible from code.
*   **Phase 5 - CI/CD Integration:** Integrate the Terraform and Ansible automation into a Jenkins or GitHub Actions pipeline to create a fully automated deployment workflow.