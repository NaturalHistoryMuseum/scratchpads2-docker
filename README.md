Scratchpads Docker
=================

Run private instances of scratchpads2 sites.

Requirements
------------

You'll need docker and docker-compose installed.

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

The `-d` option should point to your exported database and the `-s` option should point to your exported files.
The directory should be the domain name of your scratchpad; if not you must use the `-n` flag to set the domain name.

If you have a local version of the scratchpads source code, you can specify it as an argument
and it will be mounted as a volume on the source directory in the apache container:

    ./import.sh -d ../db.sql -s ../pad.myspecies.info ../scratchpads2

After running import, the `docker-compose up` command will now bring up your imported site. To return to default settings,
delete the `docker-compose.override.yml` file and the `.env` file.