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
