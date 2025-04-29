FROM golang:1.23.8-alpine3.21
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk update && apk add openssl gcc musl-dev pkgconfig zeromq-dev git g++ libstdc++ zlib-dev && apk cache purge
ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct \
    CGO_ENABLED=1 \
    GOOS=linux
RUN go env -w GOCACHE=/go-cache
RUN go env -w GOMODCACHE=/gomod-cache