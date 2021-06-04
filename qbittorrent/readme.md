## 特点

- 自动按`tracker`分类；
- 下载完成发送通知，可选途径：钉钉, Telegram, ServerChan, 爱语飞飞；
- 故障时发送通知，可选途径同上；
- 日志输出到docker控制台，可从portainer查看；
- 集成了`python`；
- 即使集成了`python`，体积仍然很小；
- 每4小时检查一下tracker状态，如发现种子的tracker状态有问题，将给该种子添加`TrackerError`的标签，方便筛选；
- 多标签可用，其中`latest` `4` `4.x` `4.x.x`是多平台标签，可用平台：`amd64` `arm/v7` `arm64`，其他标签均为单平台标签。

[!效果图](notify.png)

## 创建

1. docker cli

```
docker run -dit \
  -v $PWD/qbittorrent:/data \
  -e TZ="Asia/Shanghai" \
  -e WEBUI_PORT=8080 `# WEBUI控制端口，可自定义` \
  -e BT_PORT=34567   `# BT监听端口，可自定义` \
  -p 8080:8080       `# 冒号左右一致，要同WEBUI_PORT` \
  -p 34567:34567/tcp `# 冒号左右一致，要同BT_PORT` \
  -p 34567:34567/udp `# 冒号左右一致，要同BT_PORT` \
  --restart always \
  --name qbittorrent \
  --hostname qbittorrent \
  nevinee/qbittorrent
```

armv7设备如若无法使用网络，可能是seccomp问题，详见 [这里](https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.13.0#time64_requirements)。可以增加`--security-opt seccomp=unconfined` 来解决。

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
      - WEBUI_PORT=8080   # WEBUI控制端口，可自定义
      - BT_PORT=34567     # BT监听端口，可自定义
      - TZ=Asia/Shanghai  # 时区
    ports:
      - 8080:8080        # 冒号左右一致，必须同WEBUI_PORT
      - 34567:34567      # 冒号左右一致，必须同BT_PORT
      - 34567:34567/udp  # 冒号左右一致，必须同BT_PORT
```

如若想将qbittorrent建立在已经创建好的macvlan网络上，可以按如下方式创建：

```
version: "2.0"
services:
  qbittorrent:
    image: nevinee/qbittorrent
    container_name: qbittorrent
    restart: always
    tty: true
    networks: 
      <你的macvlan网络名称>:
        ipv4_address: <你想设置的ip>
        aliases:
          - qbittorrent
    hostname: qbitorrent
    volumes:
      - ./data:/data
    environment:
      - WEBUI_PORT=8080   # WEBUI控制端口，可自定义
      - BT_PORT=34567     # BT监听端口，可自定义
      - TZ=Asia/Shanghai  # 时区

networks: 
  <你的macvlan网络名称>:
    external: true
```

armv7设备如若无法使用网络，可能是seccomp问题，详见 [这里](https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.13.0#time64_requirements)。可以在docker-compose.yml中增加以下内容来解决：

```
    security_opt:
      - seccomp=unconfined
```

## 环境变量清单

在创建命令中，包括已经提及的`WEBUI_PORT`, `BT_PORT`, `TZ`在内，总共以下环境变量，请根据需要自行添加到创建命令中：

| 序号 | 变量名              | 默认值        | 说明 |
| :-: | :-:                | :-:           | -    |
|  1  | PUID               | 1500          | 用户的uid，以该用户运行qbittorrent-nox。 |
|  2  | PGID               | 1500          | 用户的gid，以该用户运行qbittorrent-nox。 |
|  3  | TZ                 | Asia/Shanghai | 时区 |
|  4  | UMASK_SET          | 000           | umask|
|  5  | TG_USER_ID         |               | 通知渠道telegram，如需使用需要和 TG_BOT_TOKEN 同时赋值，私聊 @getuseridbot 获取。 |
|  6  | TG_BOT_TOKEN       |               | 通知渠道telegram，如需使用需要和 TG_USER_ID 同时赋值，私聊 @BotFather 获取。 |
|  7  | DD_BOT_TOKEN       |               | 通知渠道钉钉，如需使用需要和 DD_BOT_SECRET 同时赋值，机器人设置中webhook链接`access_token=`后面的字符串（不含`=`以及`=`之前的字符）。 |
|  8  | DD_BOT_SECRET      |               | 通知渠道钉钉，如需使用需要和 DD_BOT_TOKEN 同时赋值，机器人设置中启用`加签`，加签的秘钥，形如：`SEC1234567890abcdefg`。 |
|  9  | IYUU_TOKEN         |               | 通知渠道爱语飞飞，通过 http://iyuu.cn/ 获取。 |
|  10 | SCKEY              |               | 通知渠道ServerChan，通过 http://sc.ftqq.com/3.version 获取。 |
|  11 | CRON_HEALTH_CHECK  | 12 * * * *    | 宕机检查的cron，在设定的cron运行时如发现qbittorrent-nox宕机了，则向设置的通知渠道发送通知，在docker cli中请用一对双引号引起来，在docker-compose中不要增加引号。 |
|  12 | CRON_AUTO_CATEGORY | 32 */2 * * *  | 自动分类的cron，在设定的cron将所有种子按tracker分类，在docker cli中请用一对双引号引起来，在docker-compose中不要增加引号。对于种子很多的大户人家，建议把cron频率修改低一些，一天一次即可。 |
|  13 | CRON_TRACKER_ERROR | 52 */4 * * *  | 检查tracker状态是否健康的cron，在设定的cron将检查所有种子的tracker状态，如果有问题就打上`TrackerError`的标签，在docker cli中请用一对双引号引起来，在docker-compose中不要增加引号。对于种子很多的大户人家，建议把cron频率修改低一些，一天一次即可。 |
|  14 | DL_FINISH_NOTIFY   | true          | 默认会在下载完成时向设定的通知渠道发送种子下载完成的通知消息，如不想收此类通知，则输入`false` |

## 目录说明

只需要映射一个目录给容器（当然你要映射其他目录作为下载目录也没有问题），在映射的容器内的`/data`文件夹下会有以下文件夹：

```
/data
├── cache                     # qbittorrent的缓存目录
├── certs                     # 用来存放ssl证书，默认是空的，可另外使用acme.sh来申请ssl证书
├── config                    # 所有的配置文件保存目录
│   ├── qBittorrent.conf      # **配置文件，很重要，如需恢复配置此文件必须保留**
│   ├── qBittorrent-data.conf # **上传下载数据统计文件，如需恢复配置此文件必须保留**
│   └── rss                   # **rss的配置文件保存目录，如需恢复配置此文件必须保留**
├── data                      # 所有的数据文件保存目录
│   ├── BT_backup             # **torrent的快速恢复文件保存目录，如需恢复做种数据此目录必须保留**
│   ├── GeoDB                 # IP数据保存目录
│   ├── logs                  # 日志文件保存目录
│   ├── nova3                 # 启用qBittorrent搜索功能后相关文件保存目录
│   └── rss                   # rss订阅下载文件保存目录
├── downloads                 # 默认下载目录
├── logs -> data/logs         # 只是个软连接，连接到容器内的/data/data/logs
├── temp                      # 下载文件临时存放目录，默认在配置中未启用
├── torrents                  # 保存种子文件目录，默认在配置中未启用
├── watch                     # 监控目录，监控这个目录下的.torrent文件并自动下载，默认在配置中未启用
└── webui                     # 存放其他webui文件的目录，需要自己存放，默认在配置中未启用
```

*有两个星号标记的文件或目录是重要目录，恢复数据必须要有这几个。*

*在这里可以查阅所有可用的非官方webui：https://github.com/qbittorrent/qBittorrent/wiki/List-of-known-alternate-WebUIs*

## 相关问题

**如何从其他作者的镜像转移至本镜像？**

- 进入原来容器的映射目录下，在config下分别找到`qBittorrent.conf` `qBittorrent-data.conf` `rss`，在data下找到`BT_backup`，然后将其参考上面的目录树放在容器映射目录下，然后在创建容器时，保证新容器中的下载文件的保存路径和旧容器一致，并新建容器即可。

- 举例说明如何保证新容器中的下载文件的保存路径和旧容器一致，比如旧容器中下载了一个 `xxx.2020.BluRay.1080p.x264.DTS-XXX`，保存路径为`/movies`（宿主机上的真实路径为`/volume1/home/id/movies`），那么在新建新容器时，给新容器增加一个路径映射：`-v /volume1/home/id/movies:/movies`　即可。

- 注意新容器和旧容器映射路径的权限保持一致。

**遗忘登陆密码，如何重置**

```
# 如果启用了ssl
docker exec qbittorrent curl -k -X POST -d 'json={"web_ui_username":"新的用户名","web_ui_password":"新的密码"}'　https://127.0.0.1:${WEBUI_PORT}/api/v2/app/setPreferences

# 如果未启用ssl
docker exec qbittorrent curl -X POST -d 'json={"web_ui_username":"新的用户名","web_ui_password":"新的密码"}'　http://127.0.0.1:${WEBUI_PORT}/api/v2/app/setPreferences
```

**如何与emby, jellyfin, plex等等配合使用**

将需要配合使用的容器的环境变量PUID/PGID设置为一样的即可。

**启用了其他非官方webui，导致webui打不开，如何关闭**

```
# 如果启用了ssl
docker exec qbittorrent curl -k -X POST -d 'json={"alternative_webui_enabled":false}'　https://127.0.0.1:${WEBUI_PORT}/api/v2/app/setPreferences

# 如果未启用ssl
docker exec qbittorrent curl -X POST -d 'json={"alternative_webui_enabled":false}'　http://127.0.0.1:${WEBUI_PORT}/api/v2/app/setPreferences
```

## 命令

```
# 发送通知
docker exec qbittorrent notify "测试消息标题" "测试消息通知内容"

# 将所有种子按tracker进行分类，cron（CRON_AUTO_CATEGORY）如未修改会自动每两小时运行一次
docker exec qbittorrent auto-cat -a

# 将指定种子按tracker进行分类，会自动在下载完成时运行一次
docker exec qbittorrent auto-cat -i <hash>   # hash可以在种子详情中的"普通"标签页上查看到

# 下载完成时将种子分类，并发送通知，已经在配置文件中填好了
docker exec qbittorrent dl-finish <hash>     # hash可以在种子详情中的"普通"标签页上查看到

# 检查qbittorrent是否宕机，如宕机则发送通知，容器本身也会按设置的cron（CRON_HEALTH_CHECK）来运行此命令
docker exec qbittorrent health-check

# 检查所有种子的tracker状态是否有问题，如有问题，给该种子添加一个 TrackerError 的标签，如未修改CRON_TRACKER_ERROR，则会每4小时跑一次
docker exec qbittorrent tracker-error

# 查看qbittorrent日志，也可以直接在portainer控制台中看到
docker logs -f qbittorrent
```

## 说明

- [Dockerfile](https://github.com/nevinen/dockerfiles/blob/master/qbittorrent/Dockerfile)

- 参考：

  + [crazymax/qbittorrent](https://hub.docker.com/r/crazymax/qbittorrent) , 参考了Dockerfile; 
  
  + [80x86/qbittorrent](https://hub.docker.com/r/80x86/qbittorrent), 借鉴了标签和分类的理念，正因为此镜像源码未公开，且长期不更新，并且集成acme会和acme本身的项目重复，这才催生我重写代码；

  + [arpaulnet/s6-overlay-stage](https://hub.docker.com/r/arpaulnet/s6-overlay-stage), 学习了多平台镜像制作方法。

## 问题反馈

请在 [这里](https://github.com/nevinen/dockerfiles/issues) 提交。

[![dockeri.co](http://dockeri.co/image/nevinee/qbittorrent)](https://registry.hub.docker.com/nevinee/qbittorrent/)