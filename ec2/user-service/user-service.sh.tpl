#!/bin/bash

sudo apt update -y
sudo apt install -y openjdk-21-jre-headless

sudo apt install -y unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install


# Deploy Eureka
echo "Deploying Eureka Service..."
sudo mkdir -p /opt/eureka-service
sudo chown ubuntu:ubuntu /opt/eureka-service
sudo chmod 755 /opt/eureka-service
cd /opt/eureka-service

# Download JAR from S3
sudo aws s3 cp s3://my-jar-repository/spring-discovery-0.0.1-SNAPSHOT.jar /opt/eureka-service/app.jar

# Create application.yml
cat > application.yml <<EOF
server:
  port: 8761

spring:
  application:
    name: discovery-service

eureka:
  client:
    registerWithEureka: false
    fetchRegistry: false
EOF

# Run the JAR
sudo nohup java -jar /opt/eureka-service/app.jar --spring.config.location=/opt/eureka-service/application.yml > /opt/eureka-service/log.txt 2>&1 &


echo "Waiting for Eureka to start..."
sleep 15

# Deploy Stock Service
echo "Deploying Stock Service..."
sudo mkdir -p /opt/stock-service
sudo chown ubuntu:ubuntu /opt/stock-service
sudo chmod 755 /opt/stock-service
cd /opt/stock-service

# Download JAR from S3
sudo aws s3 cp s3://my-jar-repository/stock-trading-server-0.0.1-SNAPSHOT.jar /opt/stock-service/app.jar

# Create application.yml
cat > application.yml <<EOF
server:
  port: 8081

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
    enable-reflection: true

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URL}
  instance:
    non-secure-port: 9090
    non-secure-port-enabled: false
EOF

# Run the JAR
# sudo nohup java -jar app.jar --spring.config.location=application.yml > log.txt 2>&1 &
sudo nohup java -jar /opt/stock-service/app.jar --spring.config.location=/opt/stock-service/application.yml > /opt/stock-service/log.txt 2>&1 &

# Wait for Stock Service to start
echo "Waiting for Stock Service to start..."
sleep 15

# Deploy User Service
echo "Deploying User Service..."
sudo mkdir -p /opt/user-service
sudo chown ubuntu:ubuntu /opt/user-service
sudo chmod 755 /opt/user-service
cd /opt/user-service

# Download JAR from S3
sudo aws s3 cp s3://my-jar-repository/spring-grpc-user-service-0.0.1-SNAPSHOT.jar /opt/user-service/app.jar

# Create application.yml
cat > application.yml <<EOF
server:
  port: 8082

spring:
  application:
    name: user-service
  data:
    mongodb:
      uri: ${MONGODB_URI}
      database: ${MONGODB_DATABASE}
      auto-index-creation: true
eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URL}
  instance:
    non-secure-port: 9090
    non-secure-port-enabled: false

grpc:
  client:
    stockService:
      address: discovery:///stock-service
      negotiation-type: plaintext
EOF

# Run the JAR
# sudo nohup java -jar app.jar --spring.config.location=application.yml > log.txt 2>&1 &
sudo nohup java -jar /opt/user-service/app.jar --spring.config.location=/opt/user-service/application.yml > /opt/user-service/log.txt 2>&1 &

