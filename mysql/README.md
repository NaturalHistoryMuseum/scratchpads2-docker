# Scratchpads MySQL image

Use this image for either a new Scratchpad or for importing an existing Scratchpads database.
Add your exported sql file to the `/docker-entrypoint-initdb.d/` directory.

ENV variables you can set:
 - SOLR_HOSTNAME - The hostname of your solr instance
 - SOLR_CORE - The core name of your solr db
 - UNSAFE_PASSWORD - Set to any non-empty value to set *Scratchpads Team* user's password to *password*.
 - REMOVE_MODULES - Defaults to a list of modules that don't work on private instances.
                    Add more (;-delimeted) module names to disable them.

For more information see documentation for the `mysql` Docker image.

Example:

```Dockerfile
FROM sp2-mysql

COPY my-db.sql /docker-entrypoint-initdb.d/
ENV REMOVE_MODULES=$REMOVE_MODULES;other_module
```