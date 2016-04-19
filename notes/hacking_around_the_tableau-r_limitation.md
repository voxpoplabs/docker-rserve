# Hacking around the Tableau-R limitation

Given the main problem with Tableau-R integration (as I see it), is that it severely
limits the kind of things you can do with R. In particular, it limits your ability
to create new content. For example, if you have some datasource and want to hit
an API to fetch new data to enhance said source, _and the data is multicolumnar_,
you're ***out of luck***.

Concretely, if I have a list of restaurants and their
addresses, and I want to augment this data with the latitude and longitudes of the
respective addresses (which we can assume I'll retrieve through some HTTP request),
I'd need two separate `SCRIPT_REAL` functions, and thus two separate requests. This
is incredibly wasteful. It'd be smarter to be able to save these results as a table
somewhere, and let Tableau know about it.

> Yes, I know that this may seem like I'm trying to open a can with a screw-driver (to pardon a bad analogy). However, the point here is to keep my workflow in Tableau as long as possible. 

The to-be-presented work around uses a MySQL server, in addition to a working Rserve connection; however, nothing is blessed about MySQL. Any Tableau-connectable
datasource (e.g. a .csv, .xslx, a PostgreSQL or Redshift server, etc.) will do.

I'm choosing a remote data source like MySQL to mimic the (extreme) situation where
you are not locally running your Rserve instance. If you were, however, you could
bypass a lot of the rigamarole, here, by writing your (temporary) data to something
like `tmp.csv` and then connecting Tableau to that... This will probably make more
sense once you've read further. Just keep the following in the back of your head:
in the big picture, there's no difference between the exemplary MySQL table and a
local .csv that you could be writing. This procedure would work the same for
both.
 
### Big Picture Idea
Lets assume:

- We don't want to (or cannot) modify our original (read: primary) datasource --
  maybe it's sitting in a datastore somewhere where we only have read-only 
  priveleges
- We have auxiliary (read: secondary) data that we want to use while analyzing said
  datasource. 
  
Thus, merging (or joing) these data is out of the question.

Luckily, Tableau allows for 
["Data Blending"](http://www.tableau.com/learn/tutorials/on-demand/data-blending-0) 
which is just a fancy way of
saying that we can link data between disparate sources and perform a ***local***
(left or inner) join (one person calls blending a
["POST AGGREGATE JOIN"](http://www.theinformationlab.co.uk/2012/05/15/tableau-for-excel-users-part-3-data-blending/)).

Hence, our workaround here is just an exercise in having R manage data creation
(and storage) from within Tableau. What does this mean? Instead of having our `SCRIPT_*` function return anything immediately useful, we'll:

1. have it ingest relevant primary data
2. perform desired calculations
3. save results to a file/table/etc (call this `d`).
4. return something indicating that the save was successful (I use a timestamp)

From there, we either:

- connect Tableau to `d`, or
- refresh `d` if already connected

Then, we update the data relationships (via the dialogue found in 
_Data > Edit relationships_), if necessary, and start blending.

For a good example of Blending vs. Joining check out 
[this interworks blog post](https://www.interworks.com/blog/tmccullough/2015/03/24/two-use-cases-where-blending-beats-joining-tableau-83).

For Blending beginners remember the following mantra:

> _IF IT'S NOT ON THE SHEET IT WON'T BE INCLUDED IN THE BLEND._


### Using MySQL As Temporary Datasource

For this strategy to be successful, you'll need:

1. access to a MySQL server (I'm running one locally using the `mysql`
   docker container)
2. an R driver for this database (I'm using `RMySQL` and `DBI`)
3. a basic understanding of databases (really, just creating and droping tables)

Note that to make my life easier, I decided to write my `stevenpollack/btug`
docker container with the anticipation that I would link the `mysql` container to
it. Hence, the container installs the necessary R drivers, and has the following
snippet of R code for its entry point (I've cleaned it up for legibility):


```
# require DBI, magrittr, RMySQL

dbConfig <- list()
dbConfig[['drv']] <- MySQL()
dbConfig[['password']] <- Sys.getenv('MYSQL_ENV_MYSQL_ROOT_PASSWORD')
dbConfig[['port']] <- as.integer(Sys.getenv('MYSQL_PORT_3306_TCP_PORT'))
dbConfig[['host']] <- Sys.getenv('MYSQL_PORT_3306_TCP_ADDR')

tryCatch({
  dbConn <- do.call(dbConnect, dbConfig)
  dbConn %T>%
   dbGetQuery('SET NAMES \'utf8\';') %T>%
   dbGetQuery('CREATE DATABASE IF NOT EXISTS tableau;') %T>%
   dbGetQuery('USE tableau;') %>%
   dbGetQuery('SHOW DATABASES;')
 }, error = function(e) {
   print(e[['message']])
   })
```

The first block of code creates a `dbConfig` list that holds all the relevant
connection information for `DBI::dbConnect` to find and connect to the MySQL
server. The second block then attempts to connect, sets the NAMES property to
accept utf8 strings, and sets the schema to `tableau` (you can name it something
else, if you'd like) -- creating this schema if it doesn't exist -- and then
prints out all available databases (for debugging purposes).

If you're going to setup your own workaround with something else (maybe Redshift,
or PostgreSQL), then you'll want to modify the code accordingly; the environment
variables that I'm accessing in the first block are set when I link the `mysql`
container to the `stevenpollack/btug` container.

I have done this, so I don't have to keep establishing the connection
inside the string body of a `SCRIPT_*` Tableau function: I'm free to use `dbConn`
as if it was a base-R object. More importantly, initializing `dbConn` before
I start Rserve means that my temporary tables will persist even if I close Tableau
(or finish a particular table calculation). The tables will die *only once the
instance of R running Rserve is shut down*.

So, an example calculated field looks like:

```
SCRIPT_STR('
tableName <- .arg3
overwriteData <- .arg4
appendData <- .arg5

tableData <- calcStatAndCreateTable(.arg1, .arg2)

dbConn %>%
dbWriteTable(
 name = tableName,
 value = tableData,
 overwrite = overwriteData,
 append = appendData,
 temporary = TRUE)
 
Sys.time()',
ATTR([Address]), ATTR([Key Col]),
[mysql table], [overwrite table?], [append data to table?], 
)
```