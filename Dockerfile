FROM centos:7
LABEL maintainer="lemuleoluwatosin@gmail.com"

# Install Apache, unzip, Python (for gdown)
RUN yum install -y httpd unzip python3-pip && \
    pip3 install gdown && \
    yum clean all

# Set working directory to Apache's web root
WORKDIR /var/www/html

# Download file from Google Drive (replace FILE_ID with your own)
# Example: https://drive.google.com/file/d/FILE_ID/view
# Extract the FILE_ID part and use it below:
RUN gdown "https://drive.google.com/uc?id=1I-dT98YWe-hVguQxbQEKGTBnJwS8Xdhg"

# Assuming the downloaded file is wix.zip
RUN unzip wix.zip && \
    cp -rvf wix/* . && \
    rm -rf wix wix.zip

# Start Apache in foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

# Expose web server port
EXPOSE 80 22