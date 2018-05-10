Scratchpads Docker
=================

Run private instances of scratchpads2 sites.

Requirements
------------

You'll need docker and docker-compose installed.

Build
-----

You have to build the docker files before you can run anything:

    docker build -t sp2 ./apache
    docker build -t sp2-solr ./solr

Usage
-----

For basic usage, start the containers by running:

	docker-compose up

The webserver is exposed at [localhost:8080](http://localhost:8080); when running for the first time
you'll need to set up the scratchpad at [drupal's install page](http://localhost:8080/install.php).

The new scratchpad will be created as a private-server scratchpad (even if you keep the
"standard scratchpad" box ticked at the end of the install process), meaning it will have
a maintenance account created.

Use `ctrl-c` to shut down the containers.

Importing a Scratchpad
----------------------

To import an existing scratchpad, use the import command.

    ./import.sh -d ../my-scratchpad/exported-database.sql -s ../my-scratchpad/my-scratchpad.myspecies.info/

The `-d` option points to your exported database and the `-s` option points to your exported files.
The exported files directory name must be the the domain name of your scratchpad (exactly as it was exported).

If you have a local version of the scratchpads source code, you can specify it as an argument
and it will be mounted as a volume on the source directory in the apache container:

    ./import.sh -d ../db.sql -s ../pad.myspecies.info ../scratchpads2

After running import, the `docker-compose up` command will now bring up your imported site. To return to default settings, run `./import` with no arguments.

Other arguments you can use:

 - **`-p`**: Reset the `Scratchpad Team` user's password to `password`
 - **`-n [name]`**: Set the [`COMPOSE_PROJECT_NAME`](https://docs.docker.com/compose/reference/envvars/#compose_project_name) variable (e.g. to create new volumes to mount)