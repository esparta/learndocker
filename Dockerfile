FROM alpine:latest

RUN apk update
RUN apk add bash

ENV PS1 "\h:\w#"

CMD bash
