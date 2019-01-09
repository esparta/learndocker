Networking 101
===

Docker includes a lot of features about Networking for a good reason: all
would happen on your net.

An included Networking module on Docker is powerfull enough to provide a lot
of features you would need:

- Expose ports: A container can execute any numbers of daemons, some of them would need a port the most used would be a HTTP server.
- Publishing ports: Basicasilly access an exposed port (as http port)
- Link machines: By names, using tricks as modify the hostnames files

We can create a custom networks. We would only need to create it first:

```
docker network create mynet
```

The previous would create a mynet network, this network has their own range:

```
docker network inspect mynet | grep IPAM -A6
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.21.0.0/16",
                    "Gateway": "172.21.0.1"
```

The custom network in this case was assigned a subnet on 172.21.0.0/16 range.
Of course you can define more specs for your network (as IPV6 fashion, ranges),
and a lot more (use `docker network create --help` for more info).

If we run a container with this network, Docker will assign an IP on the range

```
docker container run --it --network mynet alpine:latest
#ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
9: eth0@if10: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:ac:15:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.21.0.2/16 brd 172.21.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

In the previous example the container was assigned a 172.21.0.2 IP address. Any
new container where we use the custom network would be assigned a random IP,
unless we specify one.

Sharing names
---

One of the most amazing features is the sharing names by using a custom network
and a `network-alias` option:

```
# Launching 4 instances of a container
# In this case a webserver using nginx:latest
for i in `seq 5`; do \
docker container run -d \
  --network=mynet \
  --network-alias=webserver \
   nginx:latest; done
5b42c60770b2bd019eae0df581cabdc953d750b9248fe0aae3aa8c59c1e52364
c1ee401da45fb7009a586db9a24a55529afb9df4c76bef8532e45353531b95e8
5162ae07c20d18295458789dbe1771f86eef711c31c9feeb06dc64bb45f469e5
a6f89619202844172ad28438f32272efb87afc5506d6fac442509d91b37a07a3
2ee0516ae4c479b6a61aa367a7067b8e75d32cd523b0ab5e78cc1a0f9d66f26c
```

From another container, we can verify we resolv to multiple containers:

```
docker container run -it --rm alpine:latest
#nslookup

Name:      webserver
Address 1: 172.28.5.3 webserver.mynet
Address 2: 172.28.5.5 webserver.mynet
Address 3: 172.28.5.4 webserver.mynet
Address 4: 172.28.5.1 webserver.mynet
Address 5: 172.28.5.2 webserver.mynet
```
More about it on [Networking 101][networking 101]

[networking 101]: https://learndocker.online/courses/2/96
