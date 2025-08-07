FROM openjdk:21-slim

WORKDIR /app

# Copy the compiled JAR from Maven
COPY target/myapp-1.0.0-SNAPSHOT.jar app.jar

# Default command to run the app
CMD ["java", "-jar", "app.jar"]
