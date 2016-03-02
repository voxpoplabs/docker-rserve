[![Build
Status](https://travis-ci.org/stevenpollack/docker-rserve.svg?branch=master)](https://travis-ci.org/stevenpollack/docker-rserve)

## Docker Container for RServe
- Built off of `debian:8.3` and `conda`'s R repo.
- Be sure to map the container's port 6311 to your localhost's 6311:
```bash
docker run --name Rserver -p 6311:6311 -d rserve
```
- See
  [this](http://stackoverflow.com/questions/20265682/finding-rserve-rconfig-file-on-ubuntu-13-10)
  stackoverflow post for setting the `/etc/Rserv.conf` file
