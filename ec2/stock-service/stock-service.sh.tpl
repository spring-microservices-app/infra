#!/bin/bash

sudo apt update -y
sudo apt install -y openjdk-21-jre-headless

sudo apt install -y unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install


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
sudo nohup java -jar app.jar --spring.config.location=application.yml > log.txt 2>&1 &
# sudo nohup java -jar /opt/stock-service/app.jar --spring.config.location=/opt/stock-service/application.yml > /opt/stock-service/log.txt 2>&1 &

