FROM postgres:9.4
ARG DDL_URL
ADD scripts/* /docker-entrypoint-initdb.d/
RUN apt-get update
RUN apt-get install -y wget
RUN wget ${DDL_URL}
RUN chmod 777 /
RUN chmod 777 /tmp
RUN chmod 777 Ambari-DDL-Postgres-CREATE.sql
RUN sed -i "s/\${ambariSchemaVersion}/2.4.0.0/g" Ambari-DDL-Postgres-CREATE.sql
ADD pg_hba.conf /
RUN chown postgres /pg_hba.conf
RUN mv /pg_hba.conf /var/lib/postgresql/data/
ADD scripts/* /docker-entrypoint-initdb.d/
