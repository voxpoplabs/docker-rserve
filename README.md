## Docker Containers for Rserve

[Rserve](http://www.rforge.net/Rserve/index.html) allows for R and Tableau (among others) to communicate. However,
given that Tableau isn't available for Linux, the majority of Linux users have to run tableau through a VM
(or borrow someone's mac?).  This container is meant to be a quick way to spin up a background instance of Rserve
that Tableau can communicate to, without having to install Rserve on either your host or guest machines.

There are two containers available for pulling,

1. The bare-metal `Rserve` server:
    
    ```bash
    docker pull stevenpollack/docker-rserve
    ```
  
  This image contains all the standard R packages available through [rocker/r-base](https://hub.docker.com/r/rocker/r-base/)
  as well as `Rserve`, and has a standard `Rserve` server (with port 6311 exposed) running as its
  entrypoint.
2. The demonstrative `btug` container:

    ```bash
    docker pull stevenpollack/btug
    ```
  
  This is based off of `stevenpollack/docker-rserve`, but also contains `devtools`,
  [`BayesianFirstAid`](https://github.com/rasmusab/bayesian_first_aid),
  `randomForest`, `RMySQL` and `hopach` R packages (these are used in a tableau workbook to
  demonstrate ways to integrate R and Tableau). Note that if you want to truly follow along
  with the notebook, you'll need MySQL installed on your computer. The easiest way to do
  this is with (again) docker's [mysql container](https://hub.docker.com/r/library/mysql/):
  
    ```bash
    docker pull mysql
    ```

## Running the containers:

You'll want to be sure to map the container's port 6311 to your localhost's 6311 and run the container
in the background, **BEFORE** starting Tableau. E.g.

```bash
docker run --name BTUG -p 6311:6311 -d stevenpollack/btug
```

If you are using the docker instance of MySQL, you'll want to link the two containers:

```bash
docker run --name MYSQL -p 3306:3306 -e MYSQL_ROOT_PASSWORD=swordfish -d mysql
docker run --name RSERVE --link MYSQL:mysql -p 6311:6311 -d stevenpollack/btug
```
the first command starts up the MySQL server, and the second command starts up the Rserve
serve, but links the MySQL container to it, so we can connect to it upon initialization.
(You can see how I wired that up by looking at the [btug dockerfile](btug)).

***N.B.,***
if you want to fork this and do your own crazy stuff, you'll probably want to know how to mess with
`Rserve`. In which case, check out [this](http://stackoverflow.com/questions/20265682/finding-rserve-rconfig-file-on-ubuntu-13-10)
stackoverflow post for setting the `/etc/Rserv.conf` file
