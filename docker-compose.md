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
