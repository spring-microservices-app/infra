#!/bin/bash

sudo apt update -y
sudo apt install -y openjdk-21-jre-headless

sudo apt install -y unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install


# Deploy Eureka
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

