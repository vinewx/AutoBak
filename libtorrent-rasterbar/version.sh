#!/usr/bin/env bash

set -o pipefail

dir_shell=$(cd $(dirname $0); pwd)
dir_myscripts=$(cd $(dirname $0); cd ../../myscripts; pwd)

cd $dir_shell

## 官方版本
lib_tag=$(curl -s https://api.github.com/repos/arvidn/libtorrent/tags)
ver_lib1_official=$(echo $lib_tag | jq -r .[]."name" | grep -m1 -E "v1(\.[0-9]+){2,3}$" | sed "s/v//")
ver_lib2_official=$(echo $lib_tag | jq -r .[]."name" | grep -m1 -E "v2(\.[0-9]+){2,3}$" | sed "s/v//")

## 本地版本
ver_lib1_local=$(cat 1.x.version)
ver_lib2_local=$(cat 2.x.version)

## 导入通知程序及配置
. $dir_myscripts/notify.sh
. $dir_myscripts/my_config.sh

## 检测官方版本与本地版本是否一致
if [[ $ver_lib1_official ]]; then
    if [[ $ver_lib1_official != $ver_lib1_local ]]; then
        ## 触发　Github Action 同步源代码到Gitee
        curl \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${GITHUB_MIRROR_TOKEN}" \
            -d '{"event_type":"mirror"}' \
            https://api.github.com/repos/nevinen/dockerfiles/dispatches
        
        ## 触发Github Action构建libtorrent-rasterbar-1.x镜像
        curl \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${GITHUB_MIRROR_TOKEN}" \
            -d '{"event_type":"libtorrent-rasterbar-1.x"}' \
            https://api.github.com/repos/nevinen/dockerfiles/dispatches
        
        [[ $? -eq 0 ]] && {
            notify "libtorrent-1.x已经升级" "当前官方版本: ${ver_lib1_official}\n当前本地版本: ${ver_lib1_local}\n已经向 Github Action 触发构建程序"
            echo "$ver_lib1_official" > 1.x.version
        }
    else
        echo -e "libtorrent-1.x版本无变化，均为${ver_lib1_official}"
    fi
fi

if [[ $ver_lib2_official ]]; then
    if [[ $ver_lib2_official != $ver_lib2_local ]]; then
        ## 触发　Github Action 同步源代码到Gitee
        curl \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${GITHUB_MIRROR_TOKEN}" \
            -d '{"event_type":"mirror"}' \
            https://api.github.com/repos/nevinen/dockerfiles/dispatches
        
        ## 触发Github Action构建libtorrent-rasterbar-2.x镜像
        curl \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${GITHUB_MIRROR_TOKEN}" \
            -d '{"event_type":"libtorrent-rasterbar-2.x"}' \
            https://api.github.com/repos/nevinen/dockerfiles/dispatches
        
        [[ $? -eq 0 ]] && {
            notify "libtorrent-2.x已经升级" "当前官方版本: ${ver_lib2_official}\n当前本地版本: ${ver_lib2_local}\n已经向 Github Action 触发构建程序"
            echo "$ver_lib2_official" > 2.x.version
        }
    else
        echo -e "libtorrent-2.x版本无变化，均为${ver_lib2_official}"
    fi
fi