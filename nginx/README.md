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

[using logfiles]: https://learndocker.online/courses/2/74
