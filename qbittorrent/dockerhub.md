## 特点

- 自动按`tracker`分类（也可以选择关闭自动分类）。
- 下载完成发送通知，可选途径：钉钉（[效果图](https://gitee.com/evine/dockerfiles/raw/master/qbittorrent/pictures/notify.png)）, Telegram, ServerChan, 爱语飞飞, PUSHPLUS推送加；搭配RSS功能（[RSS教程](https://www.jianshu.com/p/54e6137ea4e3)）自动下载效果很好；下载完成后还可以补充运行你的自定义脚本。
- 故障时发送通知，可选途径同上。
- 按设定的cron检查tracker状态，如发现种子的tracker状态有问题，将给该种子添加`TrackerError`的标签，方便筛选；如果tracker出错数量超过设定的阈值，给设定渠道发送通知。
- 自带批量修改tracker的功能，可精确匹配也可模糊匹配。
- 日志输出到docker控制台，可从portainer查看。
- `python`为可选安装项，设置为`true`就自动安装。
- 体积小，默认中文UI，默认东八区时区。
- 可用平台：`amd64` `386` `arm/v6` `arm/v7` `arm64` `ppc64le` `s390x`。

## 标签

- `latest`, `4.x.x`, `4.x`, `4`: qBittorrent正式发布的稳定版，其中最新的版本会额外增加`latest`标签

- `beta`, `4.x.xbetax`: qBittorrent发布的测试版，其中最新的测试版额外增加`beta`标签

## 教程

1. github: https://github.com/nevinen/dockerfiles/tree/master/qbittorrent

2. gitee: https://gitee.com/evine/dockerfiles/tree/master/qbittorrent

## 拉取数量

[![dockeri.co](http://dockeri.co/image/nevinee/qbittorrent)](https://registry.hub.docker.com/nevinee/qbittorrent/)
