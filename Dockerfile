FROM centos:latest
MAINTAINER lemuleoluwatosin@gmail.com
RUN yum install -y httpd \
zip \
unzip \
ADD https://drive.google.com/file/d/1I-dT98YWe-hVguQxbQEKGTBnJwS8Xdhg/view?usp=drive_link /var/www.html
WORKDIR /var/www/html/
RUN unzip wix.zip
RUN cp -rvf wix/* .
RUN rm -rf wix wix.zip
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EXPOSE 80