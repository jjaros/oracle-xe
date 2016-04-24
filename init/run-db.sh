#!/bin/bash

# overwrite a hostname
sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
echo "Hostname repaired.."

# execute DB
/etc/init.d/oracle-xe start 
