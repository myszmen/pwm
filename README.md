# VPM - Virtual Pulsar Machine

A Docker-based virtual environment for pulsar data analysis, including tools like `PSRCHIVE` and `DSPSR`. VPM is designed to work with `PSRFITS` (and other pulsar data) files and supports graphical interfaces through X11 forwarding or Xvfb and VNC (no X11 server running required).

## Prerequisites

- Docker installed on your system

## Installation

You can either pull the pre-built image from Docker Hub or build it yourself.

### Option 1: Pull from Docker Hub (Recommended)

```bash
docker pull myszmen/vpm:latest
```

better use the following for now

```bash
docker pull memento1315189/vpm2:latest
```

### Option 2: Build Locally

Build the Docker image with:

```bash
docker build -t vpm .
```

## Usage

### Running VPM Locally

Run the container with your data directory mounted:

```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /path/to/your/data:/home/psr/data \
  --net=host \
  myszmen/vpm:latest bash
```

### Running VPM over SSH

When connecting to a remote server with SSH, use these steps:

1. Connect to the server with X11 forwarding:
```bash
ssh -X username@server
```

2. Run the container with proper X11 authentication:
```bash
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -e XAUTHORITY=$XAUTH \
  -v $XAUTH:$XAUTH \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /path/to/your/data:/home/psr/data \
  --net=host \
  myszmen/vpm:latest bash
```

Replace `/path/to/your/data` with the actual path to your pulsar data files.

### Using Pulsar Tools

Once inside VPM, you can use various pulsar analysis tools:

#### Using psrstat
```bash
psrstat your_pulsar_file.hp
```

#### Using pazi (with graphical interface)
```bash
pazi your_pulsar_file.hp
```

## Data Management

VPM is configured to mount your local data directory to `/home/psr/data` inside the container. This means:
- Your data files remain on your host system
- Any changes to files are immediately visible both inside and outside the container
- You can easily work with new data files without rebuilding the container

## Troubleshooting

If graphical applications don't work:
- Make sure you connected with `ssh -X` or `ssh -Y`
- Check if your DISPLAY environment variable is set correctly (`echo $DISPLAY`)
- Try running a simple X11 application like `xeyes` to test X11 forwarding
- Check if xauth is installed on both local and remote systems
- Verify that X11 is running on your host system

If you get permission errors:
- Check the ownership of your data files
- Ensure your user has read/write permissions for the mounted directory

## Notes

- VPM runs as the `psr` user to ensure proper file permissions
- PGPLOT is configured for X11 display
- The working directory is set to `/home/psr/data` by default
