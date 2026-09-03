# Docker Overlay Network

An overlay network connects containers or services running on different Docker hosts.

A normal bridge network works only on one Docker host. An overlay network creates one virtual network across multiple machines.

Docker uses VXLAN to carry container network traffic between the hosts.

Overlay networks are commonly used with Docker Swarm and multi-host applications.

Important ports between Swarm hosts include:

- TCP 2377 for Swarm management
- TCP and UDP 7946 for communication between nodes
- UDP 4789 for overlay network traffic

I would use an overlay network when frontend, backend, and database services need to communicate across multiple Docker servers.
