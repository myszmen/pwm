# VPM - Virtual Pulsar Machine

A Docker-based virtual environment for pulsar data analysis, including tools like `psrstat` and `pazi`. VPM is designed to work with `.hp` (and other pulsar data) files and supports graphical interfaces through X11 forwarding.

## Prerequisites

- Docker installed on your system
- X11 server running (typically already running on Linux desktop systems)

## Building VPM

Build the Docker image with:

```bash
docker build -t vpm .
```

## Usage

### Running VPM

Run the container with your data directory mounted:

```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /path/to/your/data:/home/psr/data \
  --net=host \
  vpm bash
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
- Check if your DISPLAY environment variable is set correctly
- Verify that X11 is running on your host system

If you get permission errors:
- Check the ownership of your data files
- Ensure your user has read/write permissions for the mounted directory

## Notes

- VPM runs as the `psr` user to ensure proper file permissions
- PGPLOT is configured for X11 display
- The working directory is set to `/home/psr/data` by default
