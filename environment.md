ENV variables
===

On docker we can use `-e` flag

```
docker container run -it -e --rm "PS1=\h:\w#" esparta/myalpine:latest
```

But is tedious, we can set it up using the Dockerfile. We can convert this
flag using ENV instruction on the Dockerfile:

```
FROM alpine:latest

RUN apk update
RUN apk add bash

ENV PS1 "\h:\w#"

CMD bash
```

After this change, we build the image and run it:

```
docker container run -it --rm esparta/my-alpine
#
acc27f49250c:/#cd lib
acc27f49250c:/lib#pwd
/lib
```

All the new containers using the modified image will have this new ENV var
already set. Of course, we can combine with the `-e` flag to add more vars
or overwrite the default ones.


Assigning multiple ENVs using a file
---

We can use `--env-file` flag to set multiple ENV on execution time:

```
# app.env
MYVAR=test
FOO=bar
```

Then, use the `docker container run` command and specify the file:

```
docker container run -it --rm --env-file=app.env esparta/my-alpine
11731965e8bc:/#export
declare -x FOO="bar"
declare -x HOSTNAME="11731965e8bc"
declare -x MYVAR="test"
declare -x PS1="\\h:\\w#"
```
Our new variables are there (along with the any others we can have).

