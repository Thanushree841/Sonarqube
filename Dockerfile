FROM nexus.mycompany.com/openjdk:21-slim

WORKDIR /app

# Correct file name here
COPY target/myapp-1.0.0-SNAPSHOT.jar app.jar

CMD ["java", "-jar", "app.jar"]

