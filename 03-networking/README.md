# My Networking Homework

I ran these commands on my Ubuntu EC2 instance to practice basic Linux networking.

## IP addresses and routes

```bash
hostname -I
ip -brief address
ip route
```

![My network information](evidence/network-info.png)

I learned that `ens5` is the main EC2 network interface, `172.31.46.198` is its private IP, and the default route points to the VPC gateway.

## Ports and DNS

```bash
ss -tuln | head -n 20
getent hosts google.com
```

![Ports and DNS](evidence/ports-and-dns.png)

Port `22` was listening because I was connected through SSH. The hostname lookup also confirmed that DNS was working.

## Ping and HTTP

```bash
ping -c 4 google.com
curl -I https://example.com
```

![Ping and curl](evidence/ping-and-curl.png)

All four ping packets returned, and the HTTP request returned status `200`.

My longer notes and command table are in [network-notes.md](network-notes.md).
