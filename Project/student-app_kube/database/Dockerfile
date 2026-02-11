FROM mysql:8.0
COPY init.sql /docker-entrypoint-initdb.d/
EXPOSE 3306
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=studentdb
