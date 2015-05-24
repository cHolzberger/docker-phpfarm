phpfarm for docker
==================

This is a build file to create a [phpfarm](http://sourceforge.net/projects/phpfarm/)
setup. The resulting docker image will run Apache on 5 different ports with 5
different PHP versions:

Port | PHP Version
-----|-------------
8050 | HHVM 
8053 | 5.3.29
8054 | 5.4.32
8055 | 5.5.16
8056 | 5.6.1

Building the image
------------------

After checkout, simply run the following command:

    docker build -t cholzberger/phpfarm .

This will setup a base Debian system, install phpfarm, download and compile the four
PHP versions and setup Apache. So, yes this will take a while. See the next section
for a faster alternative.

Downloading the image
-----------------

Simply downloading the ready made image from index.docker.io is probably the fastest
way. Just run this:

    docker pull cholzberger/phpfarm

Please note that this image might be somewhat behind from what the Dockerfile would
build, but my upload speed is too limited to upload a gigabyte in a timely fashion.

Running the container
---------------------

The following will run the container and map all ports to their respective ports on the
local machine. The current working directory will be used as the document root for
the Apache server and the server it self will run with the same user id as your current
user.

    docker run --rm -t -i -e APACHE_UID=$UID -v $PWD:/var/www:rw -p 8052:8052 -p 8053:8053 -p 8054:8054 -p 8055:8055 -p 8056:8056 cholzberger/phpfarm

Above command will also remove the container again when the process is aborted with
CTRL-C. While running the Apache and PHP error log is shown on STDOUT.

Note: the entry point for this image has been defined as ''/bin/bash'' and it will
run our ''run.sh'' by default. You can specify other parameters to be run by bash
of course.

wkhtmltopdf
-----------
This Build includes the offical wkhtmltox debian packages

Apache Magic
------------
This images adds an automatic Virtual Host mapping to the source phpfarm image.

VHost folder mapping works transparently inside this image.

Let's say your docker container gets the ip 192.168.1.1. When you access http://192.168.1.1:8054 apache will give you an error. When you add an alias for the ip (via /etc/hosts or dns), e.g. host1.local, and access it via its new name http://host1.local:8054 apache will serve the folder /var/www/host1/. If the alias is host1.ad.local.lan the directory will still be /var/www/host1, because only the first part of the alias name is used to determine the path to serve.

When you access http://host2.whatever you'll get /var/www/host2 and so on... 

Please notice that the hostname always will be lowercased. You can only access folders / subdomains in lowercase.

The main purpose of this technique is to have your Projects dir mounted on /var/www with each sub-project below it. e.g. projekts/project-a, prjects/project-b ... so you can access them as project-a.whatever and project-b.whatever. In combination with phpfarm this gives project-a.whatever:8053 for project-a with php 5.3 or project-a.whatever:8054 for project-a with php verion 5.4. 

This technique is powerfull with a wildcard dns string like *.mytestdomain which maps to exactly the same ip address for all subdomains. you'll never need to touch you apache config for VHost configuration again.

See: http://httpd.apache.org/docs/2.4/rewrite/vhosts.html for more information
To Do
-----

- [ ] adjust the build process to have a single file to configure PHP versions and ports
- [ ] optimize the Dockerfile to be more space and update efficient

Feedback
--------

This is the first time I ever worked with docker. Pullrequests and hints on how
to improve the process are more than welcome.
