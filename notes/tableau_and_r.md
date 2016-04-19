Using Docker and Tableau in OS X
====================


`docker` on OS X is not like `docker` on linux. It runs in a VM with its own IP. Thus,
even if you initialize the docker container with something like

```
docker run --name Rserver -p 6311:6311 -d stevenpollack/btug
```

When you goto _Help_ > _Settings and Performance_ > _Manage R Connection_ to check the connection:

![](manage_r_connection.png)

and specify `localhost` as your server,

![](try_localhost.png)

you'll undoubtedly get an error like:

![](connection_error.png)

since your machine, `localhost`	, isn't actually hosting the `Rserve` server. Instead, you
need to get the IP of your docker VM, in my case, it is 192.168.99.100, and using this as your
server, you should see message saying something like

> Successfully connected to the Rserve service

![](connection_successful.png)

## Getting your docker VM's IP:

If you don't know what your docker VM's IP is, you can find out using `docker-machine`:

```
$ docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
default   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.10.2
```
So we see here, under the `URL` section our ip is `192.168.99.100`... Note, that you
could also use the Kinematic app to determine the exact IP and port of your service:

![](kinematic_screenshot.png)

Just click on the name of your container ("Rserver"), click _Settings_ (next to _Home_, in the upper-right), and then click on the _Ports_ tab.

### Test run Rserve:
