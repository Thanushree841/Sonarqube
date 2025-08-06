# Use Java 21 (as per your environment)
FROM openjdk:21-slim

# Set working directory
WORKDIR /app

# Copy compiled jar to container
COPY target/sonarqube-app-1.0.0-SNAPSHOT.jar app.jar

# Set default command
ENTRYPOINT ["java", "-jar", "app.jar"]
