#!/bin/bash
# ===============================================================================================================
# Скрипт для подключений репозиториев EPEL, REMI, RPMFORGE, NGINX, апдейта софта и установки необходимых пакетов
# для CENTOS 6.5
# ===============================================================================================================

cd /tmp
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
rpm --import http://dag.wieers.com/rpm/packages/RPM-GPG-KEY.dag.txt
yum -y install wget
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm --import https://fedoraproject.org/static/0608B895.txt
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
# Zabbix repostitory
rpm -ivh http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm
yum install -y yum-priorities

sed -i '/enabled=1/a\priority=10\' /etc/yum.repos.d/epel.repo && sed -i '5c\enabled=1\' /etc/yum.repos.d/remi.repo && yum -y update
echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo

# ==============================================================================================================
# Апдейтим и устанавливаем необходимые пакеты
# ==============================================================================================================

yum -y update
#yum -y install policycoreutils-python gcc make  pcre-devel subversion zlib-devel dos2unix gdb nano screen unzip wget zip p7zip unzip nano mc top htop git subversion rsync zabbix-agent
#yum --enablerepo=remi,remi-php55,nginx -y install nginx mysql mysql-devel mysql-server php-pear-Net-Socket php-pear php-common php-gd php-devel php php-mbstring php-pear-Mail php-cli php-imap php-snmp php-pdo php-xml php-pear-Auth-SASL php-ldap php-pear-Net-SMTP php-mysql spawn-fcgi

#wget http://bash.cyberciti.biz/dl/419.sh.zip
#unzip /tmp/419.sh.zip
#mv /tmp/419.sh /etc/init.d/fastcgi.sh
#chmod +x /etc/init.d/fastcgi.sh
#chkconfig fastcgi.sh on
#chkconfig nginx on
#chkconfig mysqld on
