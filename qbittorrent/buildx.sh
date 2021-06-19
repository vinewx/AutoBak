#!/usr/bin/env bash

set -e

## 要构建的平台
BUILDX_ARCH=( amd64 arm/v7 arm64 arm/v6 386 s390x )

## qBittorrent的各种版本号
RELEASE_SEMVER=${QB_FULL_VERSION}
PATCH_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-3)
MINOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-2)
MAJOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1)

## 多平台标签数组
if [[ $RELEASE_SEMVER == $PATCH_SEMVER ]]; then
    ALL_MULTIARCH_TAG=( ${MAJOR_SEMVER} ${MINOR_SEMVER} ${RELEASE_SEMVER} latest )
else
    ALL_MULTIARCH_TAG=( ${MAJOR_SEMVER} ${MINOR_SEMVER} ${PATCH_SEMVER} ${RELEASE_SEMVER} latest )
fi

## 构建镜像
IMAGES=()
for arch in "${BUILDX_ARCH[@]}"; do
    cmd_tag=""
    for tag in ${ALL_MULTIARCH_TAG[@]}; do
        cmd_tag="$cmd_tag --tag ${DOCKERHUB_REPOSITORY}:${tag}-${arch//\//-}"
    done
    echo "------------------------- 构建目标平台：linux/${arch} -------------------------"
    docker buildx build $cmd_tag \
        --cache-from "type=local,src=~/.buildx-cache" \
        --cache-to "type=local,dest=~/.buildx-cache" \
        --output "type=docker" \
        --platform linux/${arch} \
        --build-arg "QBITTORRENT_VERSION=${QB_FULL_VERSION}" \
        --build-arg "LIBTORRENT_VERSION=${LIBTORRENT_FULL_VERSION}" \
        --file ${DOCKERFILE_NAME} \
        .

    IMAGES+=( "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-${arch//\//-}" )
done

## 推送镜像
for arch in "${BUILDX_ARCH[@]}"; do
    for tag in ${ALL_MULTIARCH_TAG[@]}; do
        docker push ${DOCKERHUB_REPOSITORY}:${tag}-${arch//\//-}
    done
done

## 添加多平台标签
for tag in ${ALL_MULTIARCH_TAG[@]}; do
    docker manifest create "${DOCKERHUB_REPOSITORY}:${tag}" "${IMAGES[@]}"
    docker manifest annotate "${DOCKERHUB_REPOSITORY}:${tag}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v6" --variant "v6"
    docker manifest annotate "${DOCKERHUB_REPOSITORY}:${tag}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" --variant "v7"
    docker manifest annotate "${DOCKERHUB_REPOSITORY}:${tag}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64" --variant "v8"
done

## 推送多平台标签
for tag in ${ALL_MULTIARCH_TAG[@]}; do
    docker manifest push --purge "${DOCKERHUB_REPOSITORY}:${tag}"
done

