# zerotier docker router
This is a docker image that runs a ZeroTier and acts as a router for other containers.

## Usage
```
docker build -t zerotier-debian:latest .
docker run --network zerotier-jelly --name zerotier-jelly --privileged zerotier-debian:latest <zerotier-network-id>
```

follow zerotier managed routes [here](https://docs.zerotier.com/route-between-phys-and-virt/#configure-the-zerotier-managed-route) 