# RoboShop: A Multi-Phase DevOps Deployment Project

### **[Project Status: Phase 3 Complete (Ansible Automation)]**

This repository is the definitive artifact for the end-to-end deployment of the RoboShop microservices application on the AWS cloud. I have systematically documented and automated this project in three distinct phases to showcase a practical, hands-on journey from meticulous manual setup to scalable, declarative automation.

---

## Project Philosophy: The Automation Journey

This project is built on the principle of **progressive automation**.

1.  **Why Start with Manual Deployment?** By first performing a meticulous manual deployment and documenting every step, I gained a deep, foundational understanding of each component's dependencies, configurations, and failure points.
2.  **Why Progress to Shell Scripts?** This knowledge was then leveraged to create robust shell scripts, introducing repeatability and reducing manual error for the first time.
3.  **Why Master Ansible?** Finally, the entire process was re-architected using Ansible. This represents a move to a declarative, idempotent, and production-ready configuration management system, demonstrating the core of modern DevOps practices.

---

## Technology Stack

This project utilizes a wide range of industry-standard technologies to mirror a real-world enterprise environment.

![Ansible](https://img.shields.io/badge/ansible-%231A1924.svg?style=for-the-badge&logo=ansible&logoColor=white)
![Shell Script](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=GNUBash&logoColor=white)
![AWS](https://img.shields.io/badge/Amazon_AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Nginx](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)
![NodeJS](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Redis](https.img.shields.io/badge/redis-%23DD0031.svg?style=for-the-badge&logo=redis&logoColor=white)

---

## Application Architecture

The infrastructure is based on a classic three-tier architecture, designed for security and scalability. Backend and database services are isolated in private network subnets, with Nginx acting as the sole, secure reverse proxy entry point.

![RoboShop Architecture Diagram](./assets/roboshop-architecture.png)

---

## Project Phases & Deliverables

| Phase 1: The Foundation <br/>**(Manual Documentation)** | Phase 2: Repeatable Automation <br/>**(Shell Scripting)** | Phase 3: Declarative Configuration <br/>**(Ansible)** |
|:----------------------------------------------------------:|:---------------------------------------------------------------:|:-----------------------------------------------------------:|
| Detailed, step-by-step guides for manually configuring each service from a base OS. This builds a deep understanding of the system. | Robust, idempotent shell scripts that automate the manual steps, designed with error-handling and flexibility. | A full-fledged Ansible implementation using roles, variables, and templates for a production-grade, declarative approach. |
| ➡️ **[Browse Manual Docs](./docs/)**                           | ➡️ **[Browse Automation Scripts](./scripts/)**                      | ➡️ **[Browse Ansible Playbooks](./ansible/)**                    |

---

## Ansible Implementation Deep Dive

The Ansible automation is structured using best practices to ensure it is modular, reusable, and easy to manage.

*   **Inventory (`inventory.ini`):** This file defines the hosts (your EC2 instances) and organizes them into logical groups (e.g., `[mongodb]`, `[web]`). This is where you map roles to machines.
*   **Roles:** Instead of one large playbook, the logic for each component is broken down into a separate **role** (e.g., `mongodb`, `catalogue`). This makes the automation modular and reusable. Each role contains:
    *   **`tasks`:** The sequence of actions to be performed.
    *   **`handlers`:** Actions that are only triggered by a notification from a task (e.g., "restart nginx").
    *   **`templates`:** Jinja2 templates (`.j2` files) are used to dynamically generate configuration files (like `nginx.conf`) based on variables.
*   **Main Playbook (`site.yml`):** This is the master playbook that serves as the entry point. It maps the roles to the host groups defined in the inventory, orchestrating the entire deployment in the correct order.

---

## How to Run the Ansible Automation

1.  **Prerequisites:**
    *   Install Ansible on your local machine.
    *   Clone this repository: `git clone https://github.com/Sarthakx67/RoboShop-Documentation.git`
    *   Provision AWS EC2 instances for each service.

2.  **Configure the Inventory:**
    *   Open the `ansible/inventory.ini` file.
    *   Replace the placeholder IP addresses with the public or private IP addresses of your EC2 instances under the appropriate host group (e.g., under `[mongodb]`, add your MongoDB server's IP).

3.  **Execute the Playbook:**
    *   Navigate to the `ansible/` directory.
    *   Run the master playbook with the following command:

    ```sh
    ansible-playbook -i inventory.ini site.yml
    ```
    Ansible will then connect to each host via SSH and run the assigned roles to configure the entire RoboShop application stack automatically.

---

## Future Roadmap

The completion of the Ansible automation marks a significant milestone. The next logical phases to further enhance this project are:

*   **Phase 4: Infrastructure as Code (IaC) with Terraform:**
    *   Write Terraform code to automatically provision the entire AWS infrastructure stack defined in the architecture (VPC, Subnets, EC2 instances, Security Groups). This will make the environment itself fully automated and reproducible.
*   **Phase 5: Continuous Integration (CI/CD) with Jenkins:**
    *   Create a CI/CD pipeline using Jenkins. This pipeline would automatically execute the Terraform and Ansible jobs, creating a complete workflow from a `git push` to a fully deployed and running application.