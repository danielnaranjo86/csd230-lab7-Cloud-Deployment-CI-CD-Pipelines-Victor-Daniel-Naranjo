# --- STAGE 1: Build the React Frontend ---
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
# Vite is configured to build into ../src/main/resources/static
# see configuration at frontend/vite.config.js
RUN npm run build

# --- STAGE 2: Build the Spring Boot Backend ---
FROM maven:3.9.6-eclipse-temurin-17-alpine AS backend-build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Pull in the built frontend assets from Stage 1
COPY --from=frontend-build /app/src/main/resources/static ./src/main/resources/static
# Build the executable JAR
RUN mvn clean package -DskipTests

# --- STAGE 3: Final Runtime ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=backend-build /app/target/*.jar app.jar

# We don't hardcode EXPOSE because Render uses $PORT
ENTRYPOINT ["java", "-Xmx512m", "-jar", "app.jar"]