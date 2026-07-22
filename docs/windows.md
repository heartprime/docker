# Install Docker on Windows

Install [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/):

1. Confirm that hardware virtualization is enabled and that your supported
   Windows 10 or Windows 11 installation can use WSL 2.
2. Download and run `Docker Desktop Installer.exe`.
3. Choose the recommended per-user installation and WSL 2 backend unless your
   environment requires Windows containers or Hyper-V.
4. Start Docker Desktop, accept the agreement, and wait until the engine is
   running.

Verify the installation in PowerShell:

```powershell
docker run --rm hello-world
docker version
docker compose version
docker buildx version
```

Review Docker Desktop's license terms before using it for commercial work.
Docker Desktop is not supported on Windows Server; consult the official
installation guide for current system requirements and alternatives.
