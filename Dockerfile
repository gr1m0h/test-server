ARG PACKAGE=github.com/grimoh/test-server

# build
FROM golang:1.25-alpine as builder

WORKDIR /go/src/$PACKAGE

RUN apk add --update --no-cache \
    git

ENV \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

COPY go.mod go.sum ./
RUN GO111MODULE=on go mod download

COPY . .

RUN go build -o /opt/test-server app/main.go

# run
FROM alpine:3.22 as executor

WORKDIR /opt
COPY --from=builder /opt /opt
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /go/src /go/src

ENV \
    PATH=/opt:$PATH

USER 12345
CMD ["test-server"]
