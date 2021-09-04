## 简介

https://github.com/ledccn/IYUUPlus ，官方提供了Docker镜像的，建议选择官方的镜像。

本镜像唯一的修改点：可以自定义更新大佬脚本和重启程序的cron（原镜像更新脚本时间为同一时间，但gitee同一时间仅允许5个连接，导致更新不了），如不自定义则每次启动容器时生成随机cron。

## 本镜像创建

```
version: "2.0"
services:
  iyuuplus:
    image: nevinee/iyuuplus
    container_name: iyuuplus
    restart: always
    network_mode: bridge
    hostname: iyuuplus
    volumes:
      - ./IYUU:/IYUU  # 首次启动前映射的IYUU文件夹必须是空的
    ports:
      - 8787:8787
    #environment:
      #- CRON_UPDATE=    # 更新脚本的cron，如需要自定义请解除这两行注释，并给CRON_UPDATE赋值
```

创建后访问：`http://<ip>:8787`

## 构建相关

https://github.com/nevinen/dockerfiles/tree/master/iyuuplus

https://github.com/nevinen/dockerfiles/tree/master/.github/workflows