FROM mysql:5.6

ENV MYSQL_ROOT_PASSWORD=platypodes \
    MYSQL_DATABASE=sp2

COPY my.cnf /etc/mysql/conf.d/my.cnf
COPY overrides.sh /sp-entry.sh

VOLUME /var/lib/mysql

ENTRYPOINT ["/sp-entry.sh"]

ENV SOLR_HOSTNAME=solr \
    SOLR_CORE=scratchpads2 \
    REMOVE_MODULES="twitter;scratchpads_twitter;twitter_pull;scratchpads_citethispage"