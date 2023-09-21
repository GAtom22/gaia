# Compile the gaiad binary
FROM golang:1.20-alpine AS build-env
WORKDIR /src/app/

RUN set -eux; apk add --no-cache ca-certificates=20230506-r0 build-base=0.5-r3 git=2.40.1-r0 linux-headers=6.3-r0

# update here the version you want to build 
ARG VERSION=v12.0.0

RUN git clone -b ${VERSION} --single-branch https://github.com/cosmos/gaia.git
WORKDIR /src/app/gaia

RUN CGO_ENABLED=0 make build
RUN go install github.com/MinseokOh/toml-cli@latest

FROM alpine:3.18
WORKDIR /root

COPY --from=build-env /src/app/gaia/build/gaiad /usr/bin/gaiad
COPY --from=build-env /go/bin/toml-cli /usr/bin/toml-cli

RUN apk add --no-cache ca-certificates=20230506-r0 jq=1.6-r3 curl=8.2.1-r0 bash=5.2.15-r5 vim=9.0.1568-r0 lz4=1.9.4-r4 rclone=1.62.2-r4 \
    && addgroup -g 1000 gaia \
    && adduser -S -h /home/gaia -D gaia -u 1000 -G gaia

USER 1000
WORKDIR /home/gaia

EXPOSE 26656 26657 1317 9090 8545 8546

CMD ["gaiad"]
