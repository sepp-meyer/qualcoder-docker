# QualCoder Docker Setup

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Directory Structure](#2-directory-structure)
  - [3. Building the Docker Images](#3-building-the-docker-images)
  - [4. Starting the Containers](#4-starting-the-containers)
- [Usage](#usage)
  - [Accessing QualCoder](#accessing-qualcoder)
  - [Accessing FileBrowser](#accessing-filebrowser)
- [Data Persistence](#data-persistence)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This project provides a Docker-based setup for running **QualCoder**, a qualitative data analysis tool, alongside **FileBrowser**, a web-based file management application. The setup leverages **noVNC** to allow users to interact with QualCoder's graphical user interface directly through a web browser, eliminating the need for a traditional desktop environment.

## Features

- **QualCoder Integration**: Perform qualitative data analysis with QualCoder in an isolated Docker environment.
- **File Management**: Manage your project files seamlessly using FileBrowser.
- **Web-Based GUI**: Access QualCoder's GUI through your web browser via noVNC.
- **Data Persistence**: Shared Docker volumes ensure your data remains intact across container restarts.
- **Modular Architecture**: Separate containers for QualCoder and FileBrowser for better resource management and scalability.

## Architecture

The setup consists of two main Docker services:

1. **QualCoder Service (`qualcoder-docker`)**
   - **Base Image**: Python 3.12-slim
   - **Components**:
     - **QualCoder**: The main application for qualitative data analysis.
     - **noVNC**: Provides a web-based VNC client to access the QualCoder GUI.
     - **Xvfb**: A virtual framebuffer to run GUI applications in a headless environment.
     - **x11vnc**: Bridges the virtual display to VNC.
     - **Fluxbox**: A lightweight window manager.
     - **Websockify**: Translates WebSocket connections to VNC.

2. **FileBrowser Service (`filebrowser-docker`)**
   - **Image**: `filebrowser/filebrowser:s6`
   - **Components**:
     - **FileBrowser**: A web-based file management tool for easy file access and organization.

Both services share a common data volume (`./data`) to facilitate seamless file management and data persistence.

## Prerequisites

- **Docker**: Ensure Docker is installed on your system. [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: Ensure Docker Compose is installed. [Install Docker Compose](https://docs.docker.com/compose/install/)
- **Sufficient Disk Space**: Ensure you have enough disk space for Docker images and data storage.

## Installation

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/yourusername/qualcoder-docker-setup.git
cd qualcoder-docker-setup
```

### 2. Directory Structure

Ensure the project directory has the following structure:

```
qualcoder-docker-setup/
├── Dockerfile.qualcoder
├── docker-compose.yml
├── start-qualcoder.sh
└── data/  # Shared data directory (will be created if not present)
```

If the `data/` directory does not exist, create it:

```bash
mkdir data
```

### 3. Building the Docker Images

Build the Docker images using Docker Compose:

```bash
docker-compose build --no-cache
```

**Note**: The build process may take several minutes as it downloads and installs all necessary dependencies.

### 4. Starting the Containers

Start the Docker containers in detached mode:

```bash
docker-compose up -d
```

Verify that the containers are running:

```bash
docker-compose ps
```

You should see both `qualcoder-docker` and `filebrowser-docker` listed as running.

## Usage

### Accessing QualCoder

QualCoder's graphical interface is accessible via your web browser using noVNC. Follow these steps:

1. Open your preferred web browser.
2. Navigate to: [http://localhost:8080](http://localhost:8080)
3. You should see the noVNC interface displaying the QualCoder GUI.

**Troubleshooting**:

- If the QualCoder GUI does not appear, ensure that all QualCoder-related services are running correctly.
- Check the container logs for any errors:

  ```bash
  docker logs qualcoder-docker
  ```

### Accessing FileBrowser

FileBrowser allows you to manage your project files through a user-friendly web interface.

1. Open your preferred web browser.
2. Navigate to: [http://localhost:8081](http://localhost:8081)
3. You should see the FileBrowser interface.

**Default Credentials**:

- **Username**: `admin`
- **Password**: `admin`

**Recommendation**: For security reasons, change the default password upon first login.

## Data Persistence

The `./data` directory on your host machine is mounted to both Docker containers:

- **QualCoder Data**: `/app/QualCoder/data`
- **FileBrowser Data**: `/srv`

This shared volume ensures that all data and project files are persistent and accessible across container restarts.

**Important**: Ensure that the `data/` directory has appropriate read/write permissions to prevent any access issues.

## Configuration

### Environment Variables

- **DISPLAY**: Specifies the display server. Set to `:0` for Xvfb.

### Ports

- **8080**: noVNC interface for QualCoder GUI.
- **8081**: FileBrowser web interface.

**Customization**: If these ports are already in use or need to be changed, update the `docker-compose.yml` file accordingly.

### Resource Limits (Optional)

To manage resource allocation, you can set CPU and memory limits in the `docker-compose.yml` file:

```yaml
services:
  qualcoder:
    ...
    deploy:
      resources:
        limits:
          cpus: "2.0"
          memory: "4G"
    ...

  filebrowser:
    ...
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: "2G"
    ...
```

**Note**: Resource limits are primarily effective in Docker Swarm mode. For standalone Docker setups, consider managing resources at the Docker daemon level or using Docker Compose version 2 syntax.

## Troubleshooting

### Common Issues

1. **QualCoder GUI Not Displaying**
   - **Check Logs**:
     ```bash
     docker logs qualcoder-docker
     ```
   - **Ensure all Services are Running**:
     ```bash
     docker exec -it qualcoder-docker /bin/bash
     ps aux
     ```
     Look for `Xvfb`, `x11vnc`, `fluxbox`, `qualcoder`, and `websockify` processes.

2. **FileBrowser Inaccessible**
   - **Check Logs**:
     ```bash
     docker logs filebrowser-docker
     ```
   - **Ensure Proper Port Mapping**: Verify that port `8081` is not blocked by a firewall.

3. **Insufficient Disk Space**
   - **Check Disk Usage**:
     ```bash
     df -h
     ```
   - **Clean Up Docker Resources**:
     ```bash
     docker system prune -a --volumes
     ```
     **Warning**: This will remove all stopped containers, unused images, networks, and volumes.

4. **Permission Issues with Data Directory**
   - **Check Permissions**:
     ```bash
     ls -ld ./data
     ```
   - **Set Correct Permissions**:
     ```bash
     chmod -R 755 ./data
     ```

### Advanced Troubleshooting

- **Interactive Debugging**:
  ```bash
  docker exec -it qualcoder-docker /bin/bash
  ```
  Inside the container, you can manually start services or inspect configurations.

- **Verify Websockify Installation**:
  ```bash
  which websockify
  ```
  This should return a valid path, e.g., `/usr/local/bin/websockify`.

- **Manually Start Services**:
  Inside the container, you can run the start script manually to observe any runtime errors:
  ```bash
  ./start-qualcoder.sh
  ```

## Contributing

Contributions are welcome! Please follow these steps to contribute:

1. **Fork the Repository**: Click the "Fork" button at the top-right corner of this page.
2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/yourusername/qualcoder-docker-setup.git
   cd qualcoder-docker-setup
   ```
3. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/YourFeatureName
   ```
4. **Commit Your Changes**:
   ```bash
   git commit -m "Add your commit message"
   ```
5. **Push to Your Fork**:
   ```bash
   git push origin feature/YourFeatureName
   ```
6. **Create a Pull Request**: Navigate to the original repository and click "New Pull Request".

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contact

For any questions, issues, or suggestions, please open an issue in the [GitHub repository](https://github.com/yourusername/qualcoder-docker-setup/issues) or contact [your.email@example.com](mailto:your.email@example.com).

---

## Acknowledgements

- **QualCoder**: [GitHub Repository](https://github.com/ccbogel/QualCoder)
- **FileBrowser**: [GitHub Repository](https://github.com/filebrowser/filebrowser)
- **noVNC**: [GitHub Repository](https://github.com/novnc/noVNC)
- **Websockify**: [GitHub Repository](https://github.com/novnc/websockify)
- **Docker**: [Official Documentation](https://docs.docker.com/)

---

**Happy Coding!** 🚀


---

## Vieleicht nimmt man auch einfach einen kleinen webtop, bei dem qualcoder bereits installiert ist
