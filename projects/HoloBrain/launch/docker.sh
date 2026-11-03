set -ex                      # set -e: 出错即退出；set -x: 打印执行的命令，便于调试

# 定义容器名字（第一个参数，默认 holobrain）
DOCKER_NAME=${1:-holobrain}
echo ">>> Launching container: $DOCKER_NAME"

# ------------------------------------------------------------------
# docker run 参数说明：
#   -i 交互、-t 分配终端、-d 后台运行
#   --gpus all            允许容器使用所有 GPU
#   --name                容器名称
#   --user root           以 root 用户身份进入容器
#   --shm-size=128g       共享内存大小设为 128G（大负载/多进程通信需要）
#   --ipc host            使用宿主机 IPC 命名空间（共享内存通信）
#   --network host        使用宿主机网络（ROS2 DDS 通信需要）
#   --pid host            使用宿主机 PID 命名空间
#   --privileged          特权模式（访问设备、调试等需要）
#   -e USER / DOCKER_USER 传入宿主用户名
#   -e PYTHONUNBUFFERED=1 Python 输出不缓冲，日志实时可见
#   -e ROS_DOMAIN_ID=2    特别注意：多套设备时 ROS_DOMAIN_ID 不能相同，
#                         否则 ROS2 节点会互相冲突；建议第一套=1、第二套=2、第三套=3
#   -e ROS2_INSTALL_PATH  ROS2 Humble 安装路径
#   -e no_proxy           本地地址不走代理
#   -w                    容器内默认工作目录
#   -v /dev:/dev          挂载所有设备（相机、串口等）
#   -v .../data:/data     挂载数据目录（读写）
#   -v .../RoboOrchard    挂载项目代码目录
#   -v .../docker_env     挂载工作环境目录
#   镜像名                horizonrobotics/holobrain:v0-ubuntu22.04-py3.10-ros-humble-torch2.8.0
#   末尾 bash             后台运行需要常驻前台进程，否则容器会立即退出；
#                         进入容器用 docker exec -it <name> bash
# ------------------------------------------------------------------
docker run -itd \
  --gpus all \
  --name "$DOCKER_NAME" \
  --user root \
  --shm-size=128g \
  --ipc host \
  --network host \
  --pid host \
  --privileged \
  -e USER=$USER \
  -e DOCKER_USER=$USER \
  -e PYTHONUNBUFFERED=1 \
  -e ROS_DOMAIN_ID=2 \
  -e ROS2_INSTALL_PATH=/opt/ros/humble/ \
  -e no_proxy="localhost,127.0.0.1" \
  -w /home/ww_ws/RoboOrchard\
  -v /dev:/dev \
  -v /home/ww_ws/docker_dir/data:/data:rw \
  -v /home/ww_ws/wkdir/RoboOrchard:/home/ww_ws/RoboOrchard:rw \
  -v $HOME/workspace/docker_env:/home/$USER:rw \
  horizonrobotics/holobrain:v0-ubuntu22.04-py3.10-ros-humble-torch2.8.0 \
  bash