FROM ubuntu:hirsute
RUN rm -rf /bin \
    && sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt update \
    && apt-get install --no-install-recommends -y \
       software-properties-common \
       
COPY --from=nevinee/s6-overlay-stage:latest / /
ENTRYPOINT ["/init"]