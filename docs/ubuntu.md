# Install Docker on Ubuntu

Run this block on a supported 64-bit Ubuntu host to install Docker Engine and
the Docker Compose plugin from Docker's official apt repository:

```bash
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
sudo systemctl enable --now docker
sudo docker run --rm hello-world
sudo docker version
sudo docker compose version
```

The final Compose version must be 2.33.1 or newer.

To run Docker without `sudo`, add your current user to the `docker` group, then
start a shell with the new group membership:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
docker run --rm hello-world
docker compose version
```

Membership in the `docker` group grants root-level privileges. See Docker's
[Linux post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/)
for details.

For supported Ubuntu releases, firewall considerations, upgrades, and package
conflicts, see Docker's official
[Ubuntu installation guide](https://docs.docker.com/engine/install/ubuntu/).
