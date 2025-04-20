#!/bin/bash
set -e

# Install prerequisites
sudo apt-get update
sudo apt-get install -y openjdk-17-jre-headless apt-transport-https wget curl gnupg

# Add Elastic GPG & repo
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update

# Install Elasticsearch, Kibana, Logstash
sudo apt-get install -y elasticsearch kibana logstash

# Elasticsearch config
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOL
network.host: 0.0.0.0
discovery.type: single-node
EOL

# Increase heap size for better performance
# sudo sed -i 's/^-Xms.*/-Xms1g/' /etc/elasticsearch/jvm.options.d/jvm.options || true
# sudo sed -i 's/^-Xmx.*/-Xmx1g/' /etc/elasticsearch/jvm.options.d/jvm.options || true

# Kibana config
sudo sed -i 's|#server.host:.*|server.host: "0.0.0.0"|' /etc/kibana/kibana.yml
sudo sed -i 's|#server.port:.*|server.port: 5601|' /etc/kibana/kibana.yml

# Enable and start services
sudo systemctl daemon-reexec
sudo systemctl enable elasticsearch kibana logstash
sudo systemctl restart elasticsearch
sleep 10
sudo systemctl restart kibana
sudo systemctl restart logstash
