[![Build
Status](https://travis-ci.org/stevenpollack/docker-rserve.svg?branch=master)](https://travis-ci.org/stevenpollack/docker-rserve)

## Docker Container for Rserve

[Rserve](http://www.rforge.net/Rserve/index.html) allows for R and Tableau (among others) to communicate. However,
given that Tableau isn't available for Linux, the majority of Linux users have to run tableau through a VM
(or borrow someone's mac?).  This container is meant to be a quick way to spin up a background instance of Rserve
that Tableau can communicate to, without having to install Rserve on either your host or guest machines.

## Notes:
- [Dockerhub link](https://hub.docker.com/r/stevenpollack/docker-rserve/)
- Uses `debian:8.3` as a base image, and miniconda as the source for base-R -- so it's not super light-weight,
  but still lighter than if you pulled down `rocker/base-r`. 
- Be sure to map the container's port 6311 to your localhost's 6311:

    ```bash
    docker run --name Rserver -p 6311:6311 -d docker-rserve
    ```
- See
  [this](http://stackoverflow.com/questions/20265682/finding-rserve-rconfig-file-on-ubuntu-13-10)
  stackoverflow post for setting the `/etc/Rserv.conf` file
