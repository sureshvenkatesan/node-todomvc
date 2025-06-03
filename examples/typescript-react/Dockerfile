# Use an official Node.js runtime as a parent image
FROM psazuse.jfrog.io/krishnam-docker-virtual/node:20-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available) to the working directory
COPY package.json ./

# Install application dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Define environment variables
ENV NODE_ENV production

# Specify the command to run when the container starts
CMD ["npm", "start"]