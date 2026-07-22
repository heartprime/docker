# Install Docker on macOS

Install [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/):

1. Download the installer for your Mac's chip: Apple silicon or Intel.
2. Open `Docker.dmg` and drag Docker into the Applications folder.
3. Open Docker from Applications, accept the agreement, and finish the initial
   setup using the recommended settings.
4. Wait until Docker Desktop reports that the engine is running.

Verify the installation in Terminal:

```bash
docker run --rm hello-world
docker version
docker compose version
docker buildx version
```

Review Docker Desktop's license terms before using it for commercial work.
Docker supports the current and two previous major macOS releases; consult the
official installation guide for current system requirements and troubleshooting.
