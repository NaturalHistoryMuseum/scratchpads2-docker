# Scratchpads Apache

Extend this image with your existing Scratchpad's filesystem, or use it as-is for a new install.

Add your exported Scratchpad files to the /app/sites directory.

## Extending

Example  Dockerfile:

```dockerfile
FROM naturalhistorymuseum/scratchpads

COPY my-site-files /app/sites/my-site
ENV MYSQL_DATABASE=sp_db \
    MYSQL_USER=db_user \
    MYSQL_PASSWORD=db_pass \
    MYSQL_HOST=db_host \
    SOLR_HOSTNAME=solr_host \
    SOLR_CORE=solr_corename \
    BASE_URL=http://example.com \
    SITE_DIR=my-site \
    SERVER_NAME=example.com
```