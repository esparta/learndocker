Creating Images
===

We created our own image using a Dockerfile

In the Dockerfile we instruct step by step how this image will be constructed.

The basics are:

- FROM -> What's the base for this file
- RUN -> Execution of the commands in the context of the image
- CMD -> The first command to execute when running a container

In order to build or image we use the docker executable with the build command:

```
build image -t esparta/my-alpine .
```

On the previous example I'm creating a custom image on my namespace (`esparta`),
with my own name (`my-alpine`).

This was happened with the above command:

```
Step 1/4 : FROM alpine:latest
 ---> 3f53bb00af94
Step 2/4 : RUN apk update
 ---> Running in e1b3e9d470ff
fetch http://dl-cdn.alpinelinux.org/alpine/v3.8/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.8/community/x86_64/APKINDEX.tar.gz
v3.8.2-13-g106f36ecbb [http://dl-cdn.alpinelinux.org/alpine/v3.8/main]
v3.8.2-8-g684f341f68 [http://dl-cdn.alpinelinux.org/alpine/v3.8/community]
OK: 9545 distinct packages available
Removing intermediate container e1b3e9d470ff
 ---> 5eaaf3a6e936
Step 3/4 : RUN apk add bash
 ---> Running in c5346bc7f0dc
(1/5) Installing ncurses-terminfo-base (6.1_p20180818-r1)
(2/5) Installing ncurses-terminfo (6.1_p20180818-r1)
(3/5) Installing ncurses-libs (6.1_p20180818-r1)
(4/5) Installing readline (7.0.003-r0)
(5/5) Installing bash (4.4.19-r1)
Executing bash-4.4.19-r1.post-install
Executing busybox-1.28.4-r2.trigger
OK: 13 MiB in 18 packages
Removing intermediate container c5346bc7f0dc
 ---> 379e8e38737b
Step 4/4 : CMD bash
 ---> Running in 860833cf8905
Removing intermediate container 860833cf8905
 ---> f7cdb92f4390
Successfully built f7cdb92f4390
Successfully tagged esparta/my-alpine:latest
```

The `docker image build` executable run the instructions on 4 phases, just as the Dockerfile said.

Nice.
