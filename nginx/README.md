Custom nginx image
===

Here we created our new image based on a debian:9-slim image, and installed
nginx inside.

This image helped us to review the lifecycle of the docker's containers:

Basics
---

Create the image was just simple. The `FROM`, `RUN` and `CMD` instructions
of the Dockerfile made it so easy:

```
FROM debian:9-slim

RUN apt-get update
RUN apt-get install -y nginx

CMD nginx -g 'daemon off;'
```

The image was build with the usual command:

```
docker image build -t esparta/nginx:latest .
```

And runned as normal:

```
docker container run --rm --name c1 -p 80:80 esparta/nginx:latest
```

We can test it work:

```
curl localhost -I
HTTP/1.1 200 OK
Server: nginx/1.10.3
Date: Tue, 08 Jan 2019 06:39:42 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Fri, 04 Jan 2019 16:17:39 GMT
Connection: keep-alive
ETag: "5c2f8723-264"
Accept-Ranges: bytes
```

First troubleshooting
---

The container based on our custom image had a caveat: it doesn't stops
when using Ctrl+C, the reason it's related on how Docker handle the first
process (PID 1), the chapter 7 of the course (2/69) explains better why
we need to ange our Dockerfile to this:

```
# Second version of our Dockerfile
FROM debian:9-slim

RUN apt-get update
RUN apt-get install -y nginx

CMD ["nginx","-g", "daemon off;"]
```

Using logfiles
---

The second caveat of our custom nginx image is we can't have the logs
on the nginx. The reason is related to what is the nginx daeamon doing:
writing the logs to a custom file instead of the $STDOUT.

For now, instead of the change the configuration we did a workaround, changing
our Dockerfile to this:

```
FROM debian:9-slim

RUN apt-get update
RUN apt-get install -y nginx

RUN rm /var/log/nginx/access.log && ln -s /dev/stdout /var/log/nginx/access.log
RUN rm /var/log/nginx/error.log && ln -s /dev/stderr /var/log/nginx/error.log

CMD ["nginx","-g", "daemon off;"]
```

The takeaway of the lesson: If possible, try to send the logs to $STDOUT & $STDERR instead of a custom file when using container based applications. If not, linking file can solve the problem.

More about this in [Using logfiles][using logfiles].

Copying data
---

We did learn how to copy files into the image we are trying to build. Our
new Dockerfile is this:

```
FROM debian:9-slim

RUN apt-get update
RUN apt-get install -y nginx

RUN rm /var/log/nginx/access.log && ln -s /dev/stdout /var/log/nginx/access.log
RUN rm /var/log/nginx/error.log && ln -s /dev/stderr /var/log/nginx/error.log

COPY ./html /var/www/html

CMD ["nginx","-g", "daemon off;"]
```

This let us copy all the contents (one file for now) of the local html folder
into the `/var/www/html` one.

More about this in [Copying data][copying data].

Copying multiple files
---

We can also instruct the build to have multiple directories:

```
-COPY ./html /var/www/html
+COPY ./html ./html/assets/ ./html/css/ /var/www/html/

```

The caveat here is that all the files on the `assets` & `css` files into
the `/var/www/html`, but not the folder structure.

Having the previous, we just did a small change, letting docker to
copy the whole directory instead of especify multiple one.

```
FROM debian:9-slim

RUN apt-get update
RUN apt-get install -y nginx

RUN rm /var/log/nginx/access.log && ln -s /dev/stdout /var/log/nginx/access.log
RUN rm /var/log/nginx/error.log && ln -s /dev/stderr /var/log/nginx/error.log

COPY ./html/ /var/www/html/

CMD ["nginx","-g", "daemon off;"]
```

More about this on [Copying multiple files][copying multiple files]

The magic of ADD
---

The `ADD` command does more or less the same as the `COPY` command, but with
additional tricks!:

```diff
-COPY ./html/ /var/www/html/
+ADD ./html.tar.gz /var/www/
```

The previous diff show a nice change: instead of copy all the folder structure
we are instructing the build to use a compressed tar file we will expand on
the `/var/www/` folder, which will result on the same files on the image! (Neat!)

But there's more! `ADD` can also errmmm add remote files:

```diff
+ADD https://example.com/index.html /var/www/html/example.html
```

The previous diff shows how it would download a file from an external URL and
added to the `/var/www/html/` folder as `example.html`. This is also nice, but
please, only trust your own URLs, IMO is one of the wrost thing you can do
to just download files from the any other site.

Nice feature, but I'm not keeping it. Our final Dockerfile looks like this:

```
FROM debian:9-slim

RUN apt-get update
RUN apt-get install -y nginx

RUN rm /var/log/nginx/access.log && ln -s /dev/stdout /var/log/nginx/access.log
RUN rm /var/log/nginx/error.log && ln -s /dev/stderr /var/log/nginx/error.log

ADD ./html.tar.gz /var/www/

CMD ["nginx","-g", "daemon off;"]
```

More about this in [The magic of ADD][magic of ADD]

[using logfiles]: https://learndocker.online/courses/2/74
[copying data]: https://learndocker.online/courses/2/91
[copying multiple files]: https://learndocker.online/courses/2/93
[magic of ADD]: https://learndocker.online/courses/2/94
