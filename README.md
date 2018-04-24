Scratchpads Docker
=================

This is a modification of the tutum-docker-lamp docker modified to run
Drupal with the scratchpads2 platform. Significant changes include:

- Upgrade the base image to Ubuntu 16.04
- Download the latest Scratchpads2 release as the app
- Removal of mysql in favour of connecting to a dedicated database container

Usage
-----

For basic usage, start the containers by running:

	./start.sh

The webserver is exposed at [localhost:8080](http://localhost:8080); when running for the first time
you'll need to set up the scratchpad at [drupal's install page](http://localhost:8080/install.php)

Use `ctrl-c` to shut down the containers.

Running a stack
---------------

To run as a docker stack you can use the `sp2.yml` config file.
Run the following:

	docker build -t sp2 .
	docker swarm init
    docker stack deploy -c sp2.yml sp2stack

This method uses the same settings as the basic usage method, including exposing the webserver on port 8080.
Using this method you may not be able to use `localhost` to access the site. If not, try using
`127.0.0.1` or your machine's local network address.
