Scratchpads Docker
=================

Run private instances of scratchpads2 sites; useful for development and deploy.

A basic scratchpads infrastructure is made of:
 - Apache instance with PHP & Drupal
 - MySQL server
 - Solr server
 - Mailserver

This directory provides the first three, and recommends a standard image (tianon/exim4) for the last.

Requirements
------------

You'll need a recent version of docker installed.

Build
-----

If you want to work with the development versions of these images you'll have to build them.
You can do this by running `./build.sh`, which creates the following local images:

 - sp2: the apache server
 - sp2-mysql: the mysql server
 - sp2-solr: the solr server

Usage
-----

See each image's readme for more information.