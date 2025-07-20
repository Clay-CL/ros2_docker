## ROS2 Docker Image

- Contains sample image with useful tools to quickly get started with ros2

### Build Image
```bash
docker build -t ros2_dev . 
```

### Run container
```bash
docker run --privileged -v /dev:/dev -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v "$HOME/.Xauthority:/home/ubuntu/.Xauthority:rw" --network host --name ros2_dev -itd ros2_dev
```

### Exec into the container
```bash
docker exec -it ros2_dev /bin/bash
```
