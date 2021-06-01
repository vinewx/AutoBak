#!/usr/bin/env bash

## 使用 github action 编译时间实在太长了，基本上都要超时了，而一超时就容易被封账号，所以还是本地构建吧。
## 本脚本主要用来本地进行跨平台构建，只考虑了三个常用的平台：amd64, arm/v7, arm64/v8
## 运行脚本的前提：已经运行过 docker login 并已经成功登陆。
## 注意：本地编译仍然会花费好几个小时，并且极有可能中途报错，若中途报错，建议手动复制命令一条一条运行。
## 在Dockerfile同目录下运行。

set -e

## 版本、镜像名称等
export QB_FULL_VERSION=4.3.5
export LIBTORRENT_FULL_VERSION=1.2.13
export DOCKERHUB_REPOSITORY=nevinee/qbittorrent
export DOCKER_CLI_EXPERIMENTAL=enabled

## 跨平台构建相关
docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

## 跨平台builder
docker buildx create --name builder --use
SUPPORTED_PLATFORMS=$(docker buildx inspect --bootstrap | grep 'Platforms:*.*' | cut -d : -f2,3)
echo "Supported platforms: $SUPPORTED_PLATFORMS"

## 各种版本号
RELEASE_SEMVER=${QB_FULL_VERSION}
PATCH_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-3)
MINOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-2)
MAJOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1)
declare -a IMAGES

## 构建amd64
docker buildx build \
    --cache-from "type=local,src=/tmp/.buildx-cache" \
    --cache-to "type=local,dest=/tmp/.buildx-cache" \
    --output "type=image,push=true" \
    --platform linux/amd64 \
    --build-arg "QBITTORRENT_VERSION=${QB_FULL_VERSION}" \
    --build-arg "LIBTORRENT_VERSION=${LIBTORRENT_FULL_VERSION}" \
    --tag "${DOCKERHUB_REPOSITORY}:latest-amd64" \
    --tag "${DOCKERHUB_REPOSITORY}:${MAJOR_SEMVER}-amd64" \
    --tag "${DOCKERHUB_REPOSITORY}:${MINOR_SEMVER}-amd64" \
    --tag "${DOCKERHUB_REPOSITORY}:${PATCH_SEMVER}-amd64" \
    --tag "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-amd64" \
    -f Dockerfile \
    .
    
IMAGES+=( "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-amd64" )

## 构建arm/v7
docker buildx build \
    --cache-from "type=local,src=/tmp/.buildx-cache" \
    --cache-to "type=local,dest=/tmp/.buildx-cache" \
    --output "type=image,push=true" \
    --platform linux/arm/v7 \
    --build-arg "QBITTORRENT_VERSION=${QB_FULL_VERSION}" \
    --build-arg "LIBTORRENT_VERSION=${LIBTORRENT_FULL_VERSION}" \
    --tag "${DOCKERHUB_REPOSITORY}:latest-arm-v7" \
    --tag "${DOCKERHUB_REPOSITORY}:${MAJOR_SEMVER}-arm-v7" \
    --tag "${DOCKERHUB_REPOSITORY}:${MINOR_SEMVER}-arm-v7" \
    --tag "${DOCKERHUB_REPOSITORY}:${PATCH_SEMVER}-arm-v7" \
    --tag "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" \
    -f Dockerfile \
    .

IMAGES+=( "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" )

## 构建arm64/v8
docker buildx build \
    --cache-from "type=local,src=/tmp/.buildx-cache" \
    --cache-to "type=local,dest=/tmp/.buildx-cache" \
    --output "type=image,push=true" \
    --platform linux/arm64/v8 \
    --build-arg "QBITTORRENT_VERSION=${QB_FULL_VERSION}" \
    --build-arg "LIBTORRENT_VERSION=${LIBTORRENT_FULL_VERSION}" \
    --tag "${DOCKERHUB_REPOSITORY}:latest-arm64-v8" \
    --tag "${DOCKERHUB_REPOSITORY}:${MAJOR_SEMVER}-arm64-v8" \
    --tag "${DOCKERHUB_REPOSITORY}:${MINOR_SEMVER}-arm64-v8" \
    --tag "${DOCKERHUB_REPOSITORY}:${PATCH_SEMVER}-arm64-v8" \
    --tag "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64-v8" \
    -f Dockerfile \
    .

IMAGES+=( "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64-v8" )

## 增加manifest
docker manifest create "${DOCKERHUB_REPOSITORY}:latest" "${IMAGES[@]}"
docker manifest create "${DOCKERHUB_REPOSITORY}:${MAJOR_SEMVER}" "${IMAGES[@]}"
docker manifest create "${DOCKERHUB_REPOSITORY}:${MINOR_SEMVER}" "${IMAGES[@]}"
docker manifest create "${DOCKERHUB_REPOSITORY}:${PATCH_SEMVER}" "${IMAGES[@]}"
docker manifest create "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}" "${IMAGES[@]}"

docker manifest annotate "${DOCKERHUB_REPOSITORY}:latest" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" --variant "v7"
docker manifest annotate "${DOCKERHUB_REPOSITORY}:${MAJOR_SEMVER}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" --variant "v7"
docker manifest annotate "${DOCKERHUB_REPOSITORY}:${MINOR_SEMVER}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" --variant "v7"
docker manifest annotate "${DOCKERHUB_REPOSITORY}:${PATCH_SEMVER}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" --variant "v7"
docker manifest annotate "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" --variant "v7"

docker manifest annotate "${DOCKERHUB_REPOSITORY}:latest" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64-v8" --variant "v8"
docker manifest annotate "${DOCKERHUB_REPOSITORY}:${MAJOR_SEMVER}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64-v8" --variant "v8"
docker manifest annotate "${DOCKERHUB_REPOSITORY}:${MINOR_SEMVER}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64-v8" --variant "v8"
docker manifest annotate "${DOCKERHUB_REPOSITORY}:${PATCH_SEMVER}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64-v8" --variant "v8"
docker manifest annotate "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64-v8" --variant "v8"

## 推送到docker hub
docker manifest push --purge "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}"
docker manifest push --purge "${DOCKERHUB_REPOSITORY}:${PATCH_SEMVER}"
docker manifest push --purge "${DOCKERHUB_REPOSITORY}:${MINOR_SEMVER}"
docker manifest push --purge "${DOCKERHUB_REPOSITORY}:${MAJOR_SEMVER}"
docker manifest push --purge "${DOCKERHUB_REPOSITORY}:latest"

