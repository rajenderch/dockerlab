## Docker Networking Lab Manual (Bridge Network)

### Lab goal

1. Create a **custom Docker bridge network** with **subnet + gateway**
2. **Connect an existing container** to that network
3. Create **new containers** directly on that custom network
4. Practice the key **Docker networking commands** for troubleshooting

---

## 0) Prerequisites

* Docker Engine installed and running:

```bash
docker version
docker info | head
```

---

## 1) Understand default networks (baseline)

List networks:

```bash
docker network ls
```

Inspect default bridge:

```bash
docker network inspect bridge
```

Quick container IP on default bridge:

```bash
docker run -d --name c-default nginx:alpine
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' c-default
```

---

## 2) Create a custom bridge network (subnet + gateway)

### Plan an IP range (example)

* Subnet: `172.25.0.0/16`
* Gateway: `172.25.0.1`

Create the network:

```bash
docker network create \
  --driver bridge \
  --subnet 172.25.0.0/16 \
  --gateway 172.25.0.1 \
  lab-net
```

Verify:

```bash
docker network ls
docker network inspect lab-net
```

**What to check in inspect output**

* `"Driver": "bridge"`
* `"IPAM" -> "Config" -> Subnet/Gateway`
* Containers attached (later)

---

## 3) Create a container on the custom network (direct attach)

Run 2 test containers:

```bash
docker run -d --name web1 --network lab-net nginx:alpine
docker run -d --name web2 --network lab-net nginx:alpine
```

Check their IPs:

```bash
docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web1 web2
```

Test DNS-based container-to-container communication (Docker embedded DNS):

```bash
docker exec -it web1 sh -c "apk add --no-cache curl >/dev/null && curl -I http://web2"
```

> On a user-defined bridge network, containers can resolve each other by **container name**.

---

## 4) Connect an existing container to the new network

Let’s connect the existing `c-default` (created earlier on default bridge) to `lab-net`:

```bash
docker network connect lab-net c-default
```

Now `c-default` has **two network interfaces** (bridge + lab-net). Check:

```bash
docker inspect c-default --format '{{json .NetworkSettings.Networks}}' | python3 -m json.tool
```

Test name resolution from `c-default` to `web1`:

```bash
docker exec -it c-default sh -c "apk add --no-cache curl >/dev/null && curl -I http://web1"
```

(Optional) Disconnect it from default bridge (usually you don’t need this, but for labs it’s nice):

```bash
docker network disconnect bridge c-default
```

---

## 5) Create container with a fixed IP (optional advanced)

Pick an unused IP in the subnet (example `172.25.0.10`):

```bash
docker run -d --name fixed1 --network lab-net --ip 172.25.0.10 nginx:alpine
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' fixed1
```

---

## 6) Port publishing vs internal networking (important concept)

Even though containers can talk internally, to access from host you must **publish ports**:

```bash
docker run -d --name webhost --network lab-net -p 8080:80 nginx:alpine
```

Test from host:

```bash
curl -I http://localhost:8080
```

---

## 7) Key Docker networking commands (cheat sheet)

### Networks

```bash
docker network ls
docker network create --driver bridge --subnet <CIDR> --gateway <IP> <name>
docker network inspect <name>
docker network rm <name>
docker network prune
```

### Attach / detach containers

```bash
docker network connect <network> <container>
docker network disconnect <network> <container>
```

### Container network details

```bash
docker inspect <container> --format '{{json .NetworkSettings.Networks}}' | python3 -m json.tool
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container>
docker exec -it <container> ip a
docker exec -it <container> ip route
docker exec -it <container> cat /etc/resolv.conf
```

### Validate connectivity

```bash
docker exec -it <container> ping -c 2 <other-container-name>
docker exec -it <container> sh -c "apk add --no-cache curl >/dev/null && curl -I http://<name>"
```

### View docker bridge interfaces on host (Linux)

```bash
ip link show | grep -E 'docker|br-'
ip addr show | grep -E 'docker|br-'
```

### See rules Docker adds (Linux)

```bash
sudo iptables -t nat -L -n -v | head
sudo iptables -L -n -v | head
```

---

## 8) Lab tasks (student checklist)

✅ Create `lab-net` with subnet + gateway
✅ Start `web1` and `web2` on `lab-net`
✅ From `web1`, curl `web2` using container name
✅ Connect existing `c-default` to `lab-net` and validate curl to `web1`
✅ Publish a port with `-p` and test from host
✅ Inspect networks/containers and identify IP, gateway, DNS settings

---

## 9) Cleanup

```bash
docker rm -f web1 web2 webhost fixed1 c-default
docker network rm lab-net
```

