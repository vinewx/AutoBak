## 特点

- 自动按`tracker`分类；
- 下载完成发送通知，可选途径：钉钉, Telegram, ServerChan, 爱语飞飞；
- 故障时发送通知，可选途径同上；
- 日志输出到docker控制台，可从portainer查看；
- 集成了`python`。

## 创建

1. docker-cli

```
docker run -dit \
  -v $PWD/data:/data \
  -e TZ="Asia/Shanghai" \
  -e WEBUI_PORT=8080 `# WEBUI控制端口，可自定义`\
  -e BT_PORT=34567   `# BT监听端口，可自定义`\
  -p 8080:8080       `# 冒号左右一致，要同WEBUI_PORT` \
  -p 34567:34567/tcp `# 冒号左右一致，要同BT_PORT` \
  -p 34567:34567/udp `# 冒号左右一致，要同BT_PORT` \
  --restart always \
  --name qbittorrent \
  --hostname qbittorrent \
  nevinee/qbittorrent
```

2. docker-compose

```
version: "2.0"
services:
  qbittorrent:
    image: nevinee/qbittorrent
    container_name: qbittorrent
    restart: always
    tty: true
    network_mode: bridge
    hostname: qbitorrent
    volumes:
      - ./data:/data
    environment:
      - WEBUI_PORT=8080   # 可自定义
      - BT_PORT=34567     # 可自定义
      - TZ=Asia/Shanghai
    ports:
      - 8080:8080        # 冒号左右一致，必须同WEBUI_PORT
      - 34567:34567      # 冒号左右一致，必须同BT_PORT
      - 34567:34567/udp  # 冒号左右一致，必须同BT_PORT
```

## 环境变量清单

在创建命令中，包括已经提及的WEBUI_PORT, BT_PORT, TZ在内，总共以下环境变量，请根据需要自行添加到创建命令中：

| 序号 | 变量名              | 默认值        | 说明 |
| :-: | :-:                | :-:           | -    |
|  1  | PUID               | 1500          | 用户的uid，以该用户运行qbittorrent-nox |
|  2  | PGID               | 1500          | 用户的gid，以该用户运行qbittorrent-nox |
|  3  | TZ                 | Asia/Shanghai | 时区 |
|  4  | UMASK_SET          | 000           | umask|
|  5  | TG_USER_ID         |               | 通知渠道telegram，如需使用需要和TG_BOT_TOKEN同时赋值，私聊@getuseridbot获取 |
|  6  | TG_BOT_TOKEN       |               | 通知渠道telegram，如需使用需要和TG_USER_ID同时赋值，私聊@BotFather获取 |
|  7  | DD_BOT_TOKEN       |               | 通知渠道钉钉，如需使用需要和DD_BOT_SECRET同时赋值 |
|  8  | DD_BOT_SECRET      |               | 通知渠道钉钉，如需使用需要和DD_BOT_TOKEN同时赋值 |
|  9  | IYUU_TOKEN         |               | 通知渠道爱语飞飞 |
|  10 | SCKEY              |               | 通知渠道ServerChan |
|  11 | CRON_HEALTH_CHECK  | 18 * * * *    | 健康检查的cron，在docker-cli中请用一对双引号引起来，在docker-compose中不用 |
|  12 | CRON_AUTO_CATEGORY | 38 * * * *    | 自动分类的cron，在docker-cli中请用一对双引号引起来，在docker-compose中不用 |

## 目录说明

只需要映射一个目录给容器（当然你要映射其他目录作为下载目录也没有问题），在映射的容器内的`/data`文件夹下会有以下文件夹：

| 序号 | 目录名    | 用途        |
| :-: | :-:       | -           |
|  1  | cache     | qbittorrent的缓存目录 |
|  2  | certs     | 用来存放ssl证书，默认是空的 |
|  3  | config    | qbittorrent的配置文件保存目录 |
|  4  | data      | qbittorrent的数据保存目录 |
|  5  | downloads | 默认下载目录 |
|  6  | logs      | 只是个软连接，连接到容器内的`/data/data/logs` |
|  7  | temp      | 下载文件临时存放目录，默认在配置中未启用 |
|  8  | torrents  | 保存种子文件目录，默认在配置未启用 |
|  9  | watch     | 监控.torrent文件并自动下载，默认在配置未启用 |
|  10 | webui     | 存放其他webui文件的目录，需要自己存放，默认在配置未启用 |
