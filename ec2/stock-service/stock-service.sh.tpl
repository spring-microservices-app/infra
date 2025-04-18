#!/bin/bash

sudo apt update -y
sudo apt install -y openjdk-21-jdk awscli

mkdir -p /opt/stock-service
cd /opt/stock-service

# Download JAR from S3
aws s3 cp s3://my-jar-repository/stock-trading-server-0.0.1-SNAPSHOT.jar app.jar

# Create application.yml
cat > application.yml <<EOF
spring:
  application:
    name: stock-service
  data:
    mongodb:
      uri: ${MONGODB_URI}
      database: ${MONGODB_DATABASE}

grpc:
  server:
    port: 9090

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URL}
  instance:
    non-secure-port: 9090
EOF

# Run the JAR
nohup java -jar app.jar --spring.config.location=application.yml > log.txt 2>&1 &
