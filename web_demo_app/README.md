Using ENVs to configure apps
===

Once we new about how to use `-e` and `--env-file` we can make use to create our first
application.

We will use the db.env file to configure a postgresql image:

```
# db.env
POSTGRES_DB=web_app_db
POSTGRES_USER=app
POSTGRES_PASSWORD=secret
```

And the already know command to spin up a container now using the env file:

```
docker container run --env-file db.env --name pg -d postgres:9.6-alpine
```

Julian provide us a basic demo application (a web server), which need a connection
to a postgresql database using also a .env file to configure it:

```
# app.env
POSTGRES_DB=web_app_db
POSTGRES_USER=app
POSTGRES_PASSWORD=secret
POSTGRES_HOST=pg
```

If we run the container using the file:

```
docker container run --link pg \
  --env-file app.env \
  -p 9292:9292 jfahrer/demo_web_app:latest
```

And is ready to go...

```
curl localhost:9292 > first_run.html
```

We have our first HTML served using a web application connected to another container
running a postgresql 9.6 image.

The maintaner doesn't need to know how exactly the internal mechanism works, instead
just filling the blanks related to ENV variables. Database name, user and password are
enough to make it run. The web application use the hostnames to grab data from postgresql
and that's all.


##Practice: Don't use `--link`

We were advised on don't use the legacy container links, so as proposed, we can
use the prefered mechanism to communicate the containers: custom network.

First, we create the custom network if doesn't exist:

```
docker network create mynet
```

Then, spin up the postgresql using the custom network and network alias:

```
docker container run --rm --env-file=db.env \
  --network=mynet --network-alias=pg  \
  --name pg -d postgres:9.6-alpine
```

And the different web application container(s):

```
docker container run --rm --env-file=app.env \
  --network=mynet
  -p 9292:9292 jfahrer/demo_web_app:latest
```

But we can have multiple instances of the web application:


```
docker container run --rm --env-file=app.env \
  --network=mynet
  -p 9293:9292 jfahrer/demo_web_app:latest
```

With the previous example, we will be running 2 instances of the same app, but using
the same database:

```
curl localhost:9292 > second_run.html
curl localhost:9293 > two_instances.html
```

Look mom! without links!

