FROM ubuntu:hirsute
RUN rm -rf /bin
COPY --from=nevinee/s6-overlay-stage:latest / /
ENTRYPOINT ["/init"]