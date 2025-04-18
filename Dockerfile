# Stage 1: Development/Build Stage
FROM node:23-alpine AS builder

# Set working directory
WORKDIR /app

# Install necessary build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all project files
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Production (using Distroless)
FROM gcr.io/distroless/nodejs18 AS runner


# Set working directory
WORKDIR /app

# Copy necessary files from builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000


# Set the user to run the applicationGoogle’s distroless images don't include package managers 
# like apk or user management utilities like adduser
# run the container as a predefined user ID
# (in this case, UID 1000) to avoid running as root.
# This is a common practice in distroless images to enhance security.



USER 1000
# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["node", "server.js"]