Docker Compose
===

The Docker Compose (`docker-compose`) is a general utility to make our life
with docker command on command line.

Normally we can start a container adding the correct options to the `docker
container` command:

```
docker container run --rm --name c1 -p 80:80 esparta/nginx:latest
```

In the previous example we run a container, set the name of the container,
publishit a port and the image in which this container is based.

`docker-compose` to the rescue!
---

Alltrough is easy (with the practice and the help of autocomplete) to generate
our command, there's a better way to do it. As a first example we got this:

```
version: '3.3'

services:
  web:
    image: nginx:latest
    ports:
      - 80:80
    volumes:
      - ./html:/usr/share/nginx/html
```

The above is the file `docker-compose.yml`, a YAML document with auto-explicit
configuration. It reads: We want a service, their name is web, using a image
`nginx:latest`, publishing the port 80 using the port 80 in the container,
at the same time mount the folder `html` into the `/usr/share/nginx/html`
folder of the container.

Executing...

```bash
$docker-compose up
```

On the folder where our docker-compose.yml. And that's it. A new container will
be running with all the thing we need. Browsing on `localhost` we got what
we expect on our session, including the logs:

```
Creating network "nginx_default" with the default driver
Creating nginx_web_1 ... done
Attaching to nginx_web_1
web_1  | 172.22.0.1 - - [17/Feb/2019:07:54:22 +0000] "GET / HTTP/1.1" 304 0 "-"
"Mozilla/5.0 (X11; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "-"
```

Cleaning up
---

We can stop it with the normal way (`ctrl-c`), but this will keep thing on the
session. That's why we also need to shutdown whatever we create with:

```
docker-compose down
Removing nginx_web_1 ... done
Removing network nginx_default
```

In the same way `docker-compose` did create the thing, it will be cleaning up.

More about docker-compose introduction: https://learndocker.online/courses/2/129

Adding a new service
---

We can add more services to our current mix just adding a new service:

```diff
+  pg:
+    image: postgres:9.6-alpine
+    env_file:
+      - ./db.env
```

The previous diff show what we did: Adding a new service called pg, using the
image `postgres:9.6-alpine` image, and a environment file calle `db.env`:

```
POSTGRES_DB=web_app_db
POSTGRES_USER=app
POSTGRES_PASSWORD=secret
```

Running this second service would do the expected:

```
Creating network "nginx_default" with the default driver
Pulling pg (postgres:9.6-alpine)...
9.6-alpine: Pulling from library/postgres
6c40cc604d8e: Pull complete
3ea5fa93d025: Pull complete
146f5c88cacb: Pull complete
eb2d56ef9a96: Pull complete
7e4e0ef1270a: Pull complete
aad54f9c97b2: Pull complete
c42b6e0f3ebb: Pull complete
f8eea6cb6175: Pull complete
51965c33bfa2: Pull complete
Creating nginx_pg_1  ... done
Creating nginx_web_1 ... done
Attaching to nginx_pg_1, nginx_web_1
pg_1   | The files belonging to this database system will be owned by user
"postgres".
pg_1   | This user must also own the server process.
pg_1   |
pg_1   | The database cluster will be initialized with locale "en_US.utf8".
pg_1   | The default database encoding has accordingly been set to "UTF8".
pg_1   | The default text search configuration will be set to "english".
[....more stuffs]
```

Since I didn't have the image, the `docker-compose` pulled all the needed:
image and did run both, the web and pg services. Pretty neat.

More details here:

https://learndocker.online/courses/2/131

Adding a volume
---

Having a database running is ok, but we need to persist the information of that
server, we can add a volume as easy as this:

```diff
--- a/nginx/docker-compose.yml
+++ b/nginx/docker-compose.yml
@@ -12,3 +12,8 @@ services:
     image: postgres:9.6-alpine
          env_file:
                 - ./db.env
+    volumes:
+      - pg-data:/var/lib/postgresql/data
+
+volumes:
+  pg-data:
 ```

Since `docker-compose` is managing our resources, we add the volumes as an
individual resource key. The volume values at `pg` service level indicates that
volume will be used on `pg` service and mounted on `/var/lib/postgresql/data`
folder.

If we execute the `docker-compose` command, we can see how a new volume was
created:

```
$docker-compose up -d
Creating network "nginx_default" with the default driver
Creating volume "nginx_pg-data" with default driver
Creating nginx_web_1 ... done
Creating nginx_pg_1  ... done
```

More details about Using a Volume with Docker Compose, here:

https://learndocker.online/courses/2/132

Interacting on Composition
---

For the sake of demostration Julian added another service to the composing, an
alpine image:

```diff
+++ b/nginx/docker-compose.yml
@@ -15,5 +15,11 @@ services:
     volumes:
            - pg-data:/var/lib/postgresql/data

+  alpine:
+    image: alpine:latest
+    stdin_open: true
+    tty: true
+    command: sh
+
 volumes:
    pg-data:
```

After setting up with `docker-compose up -d` we can examine the state of our
composition with `docker-compose ps`:

```bash
$docker-compose ps
Name                   Command              State         Ports
---------------------------------------------------------------------------
nginx_alpine_1   sh                              Up
nginx_pg_1       docker-entrypoint.sh postgres   Up      5432/tcp
nginx_web_1      nginx -g daemon off;            Up      0.0.0.0:80->80/tcp
```

All our services are up and running. We can notice the published ports also.
Since `docker-compose` do all for us, it make the communication way to easy:

```bash
# We can communicate using the name of the container...
/ # ping nginx_pg_1
PING nginx_pg_1 (172.26.0.2): 56 data bytes
64 bytes from 172.26.0.2: seq=0 ttl=64 time=0.188 ms
64 bytes from 172.26.0.2: seq=1 ttl=64 time=0.130 ms
64 bytes from 172.26.0.2: seq=2 ttl=64 time=0.128 ms
64 bytes from 172.26.0.2: seq=3 ttl=64 time=0.166 ms
^C
--- nginx_pg_1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.128/0.153/0.188 ms

# Or using the name of the service itself

/ # ping pg
PING pg (172.26.0.2): 56 data bytes
64 bytes from 172.26.0.2: seq=0 ttl=64 time=0.136 ms
64 bytes from 172.26.0.2: seq=1 ttl=64 time=0.162 ms
64 bytes from 172.26.0.2: seq=2 ttl=64 time=0.128 ms
64 bytes from 172.26.0.2: seq=3 ttl=64 time=0.126 ms
^C
--- pg ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.126/0.138/0.162 ms
```

More details about communication on composed docker:

https://learndocker.online/courses/2/133

Scaling a service
===

In our example we did execute a service publishing an application using
an specific port (9292, in our case), we can scale de service utilizing a
load balancer as seen on previous lessons.

As a reminder, this is what does the trick in our Load Balancer:

```
server {
  listen 80 default_server;

  resolver 127.0.0.11 valid=1s;

  set $protocol $PROXY_PROTOCOL;
  set $upstream $PROXY_UPSTREAM;

  location / {
    proxy_pass $protocol://$upstream$request_uri;

    proxy_pass_header Authorization;

  [...]
```

On the previous snipet of the nginx configuration (the server we use as
Load Balancer) we define an upstream server and pass them along, that upstream
is defined via a env variable called `$PROXY_UPSTREAM` with a value of
`webapp:9292`:

```diff
diff --git a/compose_example/.env b/compose_example/.env
index a4e5fcb..83cd697 100644
--- a/compose_example/.env
+++ b/compose_example/.env
@@ -2,3 +2,4 @@ POSTGRES_DB=web_app_db
 POSTGRES_USER=app
 POSTGRES_PASSWORD=secret
 POSTGRES_HOST=pg
+PROXY_UPSTREAM=webapp:9292
```

Incorporte the new load balancer is simple as it look, just adding a new
service using the Load Balancer image:

```diff
 services:
 +  lb:
 +    image: esparta/lb:latest
 +    depends_on:
 +      - webapp
 +    environment:
 +      - PROXY_UPSTREAM
 +    ports:
 +      - 80:80
 +
    pg:
      image: postgres:9.6-alpine
      environment:
      @@ -11,9 +22,9 @@ services:
      - pg-data:/var/lib/postgresql/data

    webapp:
      image: jfahrer/demo_web_app:latest
 -    ports:
 -      - 9292:9292
 +
```

And that's it. The Load Balancer has published a port 80 and internally ask
for thr webapp, Docker will respond with any of the `webapp` ips, and that
would make it scalable. By default `docker-compose` will run only one
service declared. So we can add more with `--scale` directive:

```bash
$ docker-compose up -d --scale webapp=5

compose_example_pg_1 is up-to-date
Starting compose_example_webapp_1 ... done
Creating compose_example_webapp_2 ... done
Creating compose_example_webapp_3 ... done
Creating compose_example_webapp_4 ... done
Creating compose_example_webapp_5 ... done
compose_example_lb_1 is up-to-date
```

Resulting on more `webapp` services:

```
Name                                  Command               State         Ports
--------------------------------------------------------------------------------------
compose_example_lb_1       /start.sh                        Up      0.0.0.0:80->80/tcp
compose_example_pg_1       docker-entrypoint.sh postgres    Up      5432/tcp
compose_example_webapp_1   /app/bin/docker-entrypoint ...   Up      9292/tcp
compose_example_webapp_2   /app/bin/docker-entrypoint ...   Up      9292/tcp
compose_example_webapp_3   /app/bin/docker-entrypoint ...   Up      9292/tcp
compose_example_webapp_4   /app/bin/docker-entrypoint ...   Up      9292/tcp
compose_example_webapp_5   /app/bin/docker-entrypoint ...   Up      9292/tcp
```

De-scaling is just the inverse:

```bash
$docker-compose up -d --scale webapp=1
compose_example_pg_1 is up-to-date
Stopping and removing compose_example_webapp_2 ... done
Stopping and removing compose_example_webapp_3 ... done
Stopping and removing compose_example_webapp_4 ... done
Stopping and removing compose_example_webapp_5 ... done
Starting compose_example_webapp_1              ... done
compose_example_lb_1 is up-to-date
```

Listing the process on the composition...

```bash
$docker-compose ps

Name                                  Command               State         Ports
--------------------------------------------------------------------------------------
compose_example_lb_1       /start.sh                        Up      0.0.0.0:80->80/tcp
compose_example_pg_1       docker-entrypoint.sh postgres    Up      5432/tcp
compose_example_webapp_1   /app/bin/docker-entrypoint ...   Up      9292/tcp
```

Note: While I was testing scaling of the Load Balancer I also found a problem
it should not be happening:

```
WARNING: The "webapp" service specifies a port on the host. If multiple
containers for this service are created on a single host, the port will clash.
Starting compose_example_webapp_1 ... done
Creating compose_example_webapp_2 ... error
Creating compose_example_webapp_3 ... error
Creating compose_example_webapp_4 ... error
Creating compose_example_webapp_5 ... error

ERROR: for compose_example_webapp_2  Cannot start service webapp: driver failed
programming external connectivity on endpoint compose_example_webapp_2
(36115ad768775b052d0804709653ec05054a913ccf84187b828be5deec79dcaa): Bind for
0.0.0.0:9292 failed: port is already allocated

[... Four identical errors just chaning the ID ...]

ERROR: for webapp  Cannot start service webapp: driver failed programming
external connectivity on endpoint compose_example_webapp_2
(36115ad768775b052d0804709653ec05054a913ccf84187b828be5deec79dcaa): Bind for
0.0.0.0:9292 failed: port is already allocated

ERROR: Encountered errors while bringing up the project.
```

Even with the clear error message it wasn't that obvious what was happening. I was
trying to scale the application adding 4 more `webapp` services, but not able to
because I forgot to unpublish the ports that `webapp` was doing. Going directly
to that error, basically a: "I can't create more `webapp` services because
the port is already binded and used on the first one, if add another one you
will have a really nasty problem". Removing the `ports` section on `webapp`
solved the problem.

More about scaling on LearnDocker: https://learndocker.online/courses/2/141
