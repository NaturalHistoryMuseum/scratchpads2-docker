Scratchpads Docker
=================

Run private instances of scratchpads2 sites.

Usage
-----

For basic usage, start the containers by running:

	./start.sh

The webserver is exposed at [localhost:8080](http://localhost:8080); when running for the first time
you'll need to set up the scratchpad at [drupal's install page](http://localhost:8080/install.php).

The new scratchpad will be created as a private-server scratchpad (even if you keep the
"standard scratchpad" box ticked at the end of the install process), meaning it will have
a maintenance account created.

Use `ctrl-c` to shut down the containers.

Running a stack
---------------

To run as a docker stack you can use the `sp2.yml` config file.
Run the following:

	docker build -t sp2 apache
	docker build -t sp2-solr solr
	docker swarm init
    docker stack deploy -c sp2.yml sp2stack

This method uses the same settings as the basic usage method, including exposing the webserver on port 8080.
Using this method you may not be able to use `localhost` to access the site. If not, try using
`127.0.0.1` or your machine's local network address.
