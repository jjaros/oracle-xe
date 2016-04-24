# Use the CentOS base image
FROM centos

# Maintainer of the image
MAINTAINER Jan Jaros, jarosjan@yahoo.com

# Copy the RPM file, modified init.ora, initXETemp.ora and the installation response file
# inside the image
ADD Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm
ADD config/init.ora /tmp/init.ora
ADD config/initXETemp.ora /tmp/initXETemp.ora
ADD Disk1/response/xe.rsp /tmp/xe.rsp
ADD init/functions /etc/init.d/functions
ADD init/run-db.sh /run-db.sh

# 1. Install the necessary packages
# 2. Create directory subsys
# 3. Set root as owner of subsys directory
# 4. Set permissions of subsys directory
# 5. Make run script executable
RUN yum install -y libaio bc net-tools; \
    mkdir -p /run/lock/subsys; \
    chown root:root /run/lock/subsys; \
    chmod 755 /run/lock/subsys; \
    chmod a+x /run-db.sh;

# 1.   Install the Oracle XE RPM
# 2.   Remove unnecessary Oracle package
# 3.   Move Oracle config files to the right directory ()
# 4.   Run command to configure DB server
# 5-7. Create entries for the database in the profile
# 8.   Remove unnecessary config file
RUN yum localinstall -y /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm; \
    rm -f /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm; \
    mv /tmp/init*.ora /u01/app/oracle/product/11.2.0/xe/config/scripts; \
    /etc/init.d/oracle-xe configure responseFile=/tmp/xe.rsp; \
    echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/profile.d/oracle_profile.sh; \
    echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/profile.d/oracle_profile.sh; \
    echo 'export ORACLE_SID=XE' >> /etc/profile.d/oracle_profile.sh; \
    rm -f /tmp/xe.rsp;
 
# Expose ports 1521 and 8080
EXPOSE 1521
EXPOSE 8080

# overwrite init script
ADD init/oracle-xe /etc/init.d/oracle-xe

# Container init script
CMD /run-db.sh