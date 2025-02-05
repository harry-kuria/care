#!/bin/bash

# Step 1: Get the current directory
current_directory=$(pwd)

# Step 2: Create the project directory structure under the current directory
mkdir -p "$current_directory"/{services,shared,services/{auth-service,user-service,organization-service,health-data-service,sports-data-service,report-service,audit-service},docker}

# Step 3: Create a Docker Compose file for easy service orchestration
cat <<EOF > "$current_directory/docker/docker-compose.yml"
version: '3'
services:
  mysql:
    image: mysql:8
    container_name: mysql-container
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: safia_system
    ports:
      - "3306:3306"
    volumes:
      - ./mysql-data:/var/lib/mysql

  auth-service:
    build:
      context: ./services/auth-service
    ports:
      - "5001:5001"
    depends_on:
      - mysql

  user-service:
    build:
      context: ./services/user-service
    ports:
      - "5002:5002"
    depends_on:
      - mysql

  organization-service:
    build:
      context: ./services/organization-service
    ports:
      - "5003:5003"
    depends_on:
      - mysql

  health-data-service:
    build:
      context: ./services/health-data-service
    ports:
      - "5004:5004"
    depends_on:
      - mysql

  sports-data-service:
    build:
      context: ./services/sports-data-service
    ports:
      - "5005:5005"
    depends_on:
      - mysql

  report-service:
    build:
      context: ./services/report-service
    ports:
      - "5006:5006"
    depends_on:
      - mysql

  audit-service:
    build:
      context: ./services/audit-service
    ports:
      - "5007:5007"
    depends_on:
      - mysql
EOF

# Step 4: Create a Dockerfile template for the services
cat <<EOF > "$current_directory/docker/Dockerfile"
# Use Node.js 18 as the base image
FROM node:18

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json .
RUN npm install

# Copy all other files
COPY . .

# Expose the app port (adjust as needed)
EXPOSE 5000

# Command to start the service
CMD ["npm", "start"]
EOF

# Step 5: Create a .env file to hold environment variables
cat <<EOF > "$current_directory/.env"
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=root_password
DB_NAME=safia_system

# JWT secret
JWT_SECRET=my_jwt_secret

# Service-specific configurations (modify as necessary)
PORT=5001
EOF

# Step 6: Create the basic package.json for the project
cat <<EOF > "$current_directory/package.json"
{
  "name": "safia-system",
  "version": "1.0.0",
  "description": "Health Data Management System with Microservices Architecture",
  "main": "index.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^2.3.3",
    "jsonwebtoken": "^9.0.0",
    "dotenv": "^16.0.3"
  },
  "devDependencies": {
    "nodemon": "^2.0.19"
  },
  "author": "Your Name",
  "license": "MIT"
}
EOF

# Step 7: Create basic files for each service
create_service() {
  service_name=$1
  mkdir -p "$current_directory/services/$service_name"
  cat <<EOF > "$current_directory/services/$service_name/package.json"
{
  "name": "$service_name",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^2.3.3",
    "jsonwebtoken": "^9.0.0",
    "dotenv": "^16.0.3"
  }
}
EOF
  touch "$current_directory/services/$service_name/index.js"
}

# Create each service
create_service "auth-service"
create_service "user-service"
create_service "organization-service"
create_service "health-data-service"
create_service "sports-data-service"
create_service "report-service"
create_service "audit-service"

# Step 8: Install dependencies in the project
cd "$current_directory" && npm install

# Step 9: Setup a README for the project
cat <<EOF > "$current_directory/README.md"
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
1. Set up environment variables in the `.env` file.
2. Run `docker-compose up --build` to start all services.
EOF

# Final message
echo "Project setup is complete! You can now customize the services and start developing your application."

