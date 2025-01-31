# Use an official Amazon Linux base image
FROM amazonlinux:latest

# Update and install necessary packages
RUN yum update -y && \
    yum install -y httpd git && \
    yum clean all

# Clone the repository and copy its contents to the web server root
RUN git clone https://github.com/chagak/honey-static-webapp.git /tmp/honey-static-webapp && \
    cp -r /tmp/honey-static-webapp/* /var/www/html/ && \
    rm -rf /tmp/honey-static-webapp

# Ensure proper permissions for the Apache web server
RUN chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Start the Apache service in the foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
