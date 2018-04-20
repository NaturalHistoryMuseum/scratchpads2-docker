Scratchpads Docker
=================

This is a modification of the tutum-docker-lamp docker modified to run
Drupal with the scratchpads2 platform. Significant changes include:

- Upgrade the base image to Ubuntu 16.04
- Removal of mysql in favour of connecting to a dedicated database container

Usage
-----

To build, execute the following command in the folder:

	docker build -t sp2 .

Running your LAMP docker image
------------------------------

Start your image binding port 80 to 8080 on the host:

	docker run -d -p 8080:80 sp2

Test your deployment:

	curl http://localhost:8080/

This will load the drupal create-site form configured with scratchpads profiles.
