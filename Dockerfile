FROM ubuntu:20.04
LABEL maintainer="lemuleoluwatosin@gmail.com"

# Prevent interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, unzip, Python3 (for gdown)
RUN apt-get update && \
    apt-get install -y apache2 unzip python3-pip curl && \
    pip3 install gdown && \
    rm -rf /var/lib/apt/lists/*

# Set working directory to Apache's web root
WORKDIR /var/www/html

# Download file from Google Drive using gdown
# Replace FILE_ID with your file's ID
RUN gdown "https://drive.google.com/uc?id=1I-dT98YWe-hVguQxbQEKGTBnJwS8Xdhg"

# Unzip and set up website
RUN unzip wix.zip && \
    cp -rvf wix/* . && \
    rm -rf wix wix.zip

# Expose HTTP port
EXPOSE 80

# Start Apache in foreground
CMD ["apachectl", "-D", "FOREGROUND"]