FROM ubuntu:20.04

# Instale as dependências do Zabbix Server
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-php \
    php-mysql \
    php-ldap \
    php-mbstring \
    php-bcmath \
    php-xml \
    php-gd \
    php-zip \
    mariadb-client \
    snmp \
    fping \
    && rm -rf /var/lib/apt/lists/*

# Baixe e instale o Zabbix Server
ARG ZABBIX_VERSION=5.4
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget && \
    wget https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VERSION}-1+ubuntu20.04_all.deb && \
    dpkg -i zabbix-release_${ZABBIX_VERSION}-1+ubuntu20.04_all.deb && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    zabbix-server-mysql=${ZABBIX_VERSION}* \
    zabbix-frontend-php=${ZABBIX_VERSION}* \
    zabbix-apache-conf=${ZABBIX_VERSION}* \
    && rm -rf /var/lib/apt/lists/*

# Configure o banco de dados para o Zabbix Server
COPY zabbix_server.sql /tmp/
RUN service mysql start && \
    mysql -uroot -e "CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;" && \
    mysql -uroot zabbix < /tmp/zabbix_server.sql && \
    rm /tmp/zabbix_server.sql

# Exponha as portas do Apache e do Zabbix Server
EXPOSE 80
EXPOSE 10051

# Inicie o Apache e o Zabbix Server
CMD service apache2 start && service zabbix-server start && tail -f /var/log/zabbix/zabbix_server.log
