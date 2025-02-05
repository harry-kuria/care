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
