# RoboShop E-Commerce Platform Deployment Project

**Author:** Sarthak Singh
**Contact:** sarthakx67@gmail.com / www.linkedin.com/in/sarthak-singh-a0aa62322 

---

## Project Overview

This repository contains the complete documentation for the deployment of the RoboShop application, a polyglot, microservices-based e-commerce platform. The primary goal of this project is to serve as a portfolio piece demonstrating a practical understanding of cloud infrastructure, manual service deployment, and the foundational principles of DevOps.

The documentation is divided into a high-level architectural overview (this file) and detailed, step-by-step deployment guides for each individual component.

## Application Architecture

The RoboShop application follows a classic **Three-Tier Architecture**, which logically and physically separates components based on their function. This design enhances security, scalability, and maintainability.

Below is a conceptual diagram of the service communication and dependency flow that was implemented for this project.


![RoboShop Architecture Diagram](assets/roboshop-architecture.png)

---

### Tier 1: Presentation Tier (The Frontend)

This tier serves as the primary user-facing entry point for the entire application. It is responsible for delivering the web interface to the user's browser.

*   **Primary Technology:** Nginx is used as the web server for this tier.
*   **Key Functions:**
    *   **Serving Static Content:** Delivers the HTML, CSS, and JavaScript files that make up the user interface.
    *   **Reverse Proxy:** Acts as a gateway for all API requests. It forwards requests from the user's browser to the appropriate backend service in the application tier, hiding the internal network topology from the end-user.

### Tier 2: Application Tier (Backend Microservices)

This tier contains the core business logic of the application, broken down into multiple, independent microservices.

*   **Service Examples:** `Catalogue`, `User`, `Cart`, `Shipping`, etc.
*   **Technology:** This tier is **polyglot**, meaning different services are built with different technologies (NodeJS, Python, Java) as best fits their purpose. Most services run with their own embedded servers.
*   **Security Principle:** The entire application tier is deployed within a private network. Services here are **not accessible directly from the internet**. All inbound communication must pass through the Nginx reverse proxy in the presentation tier, creating a secure boundary.

### Tier 3: Persistence Tier (Databases & Data Stores)

This tier handles all data storage, caching, and messaging needs for the application. It is also deployed in a private network, accessible only by the services in the application tier that require it.

*   **Relational Database (RDBMS):** Systems like **MySQL** are used for structured data that requires high transactional integrity, such as user profiles and order history.
*   **NoSQL Database:** **MongoDB** is used to store less structured, document-based data, making it ideal for the product catalog.
*   **In-Memory Cache:** **Redis** provides a high-speed caching layer. It stores frequently accessed data (like user sessions) in memory to reduce response times and decrease load on the primary databases.
*   **Message Broker (MQ):** **RabbitMQ** enables asynchronous communication between services. This decouples services from each other, improving resilience. For example, an `orders` service can publish a "new order placed" message, which a `shipping` service can consume independently without the two needing to communicate directly.