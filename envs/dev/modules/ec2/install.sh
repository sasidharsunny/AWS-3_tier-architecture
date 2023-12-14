#!/bin/bash
#VM Startup Script
# sudo yum update -y
# sudo amazon-linux-extras install docker -y
# sudo systemctl enable docker --now
# sudo systemctl enable containerd.service --now
# sudo usermod -a -G docker ec2-user
# sudo docker pull bjwrd/app.py
# sudo docker run -d bjwrd/app.py 

or 

#!/bin/bash
#VM Startup Script
#!/bin/bash

# Update the package repository and install a web server (e.g., Apache)
sudo yum update -y
sudo yum install -y httpd

# Start the web server
sudo service httpd start

# Create a directory for the web content
sudo mkdir /var/www/html

# Create and deploy the index.html file
echo "<html><head><title>My Website</title></head><body><h1>Hello, AWS!</h1></body></html>" | sudo tee /var/www/html/index.html

# Set the correct permissions
sudo chmod 644 /var/www/html/index.html

# Restart the web server to apply changes
sudo service httpd restart

