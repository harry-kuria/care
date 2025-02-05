# Safia Health Data Management System

This project is a microservices-based health data management system. The system provides functionalities for managing organizations, users, health data, sports data, reports, and audit logs. The system is built using Node.js, Express.js, and MySQL.

## Features
- User roles and permissions management (Superadmin, Internal Users, Clients)
- Health data collection and tracking
- Sports data collection and analysis
- Analytics and reporting
- Secure data access and compliance with data privacy laws

## Services
- **auth-service**: Handles user authentication (JWT/OAuth).
- **user-service**: Manages user data and roles.
- **organization-service**: Manages organizations and their settings.
- **health-data-service**: Manages client health data.
- **sports-data-service**: Manages sports data.
- **report-service**: Generates analytics and reports.
- **audit-service**: Tracks user activity for compliance.

## How to Run
1. Set up environment variables in the  file.
2. Run  to start all services.
