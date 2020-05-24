FROM golang:1.13-alpine AS builder

RUN apk update && apk add --no-cache git

WORKDIR /go/src/app
COPY main.go .
COPY devsecopspipeline/ .

RUN env GIT_TERMINAL_PROMPT=1 go get -d -v .
RUN CGO_ENABLED=0 go build -o /go/bin/app

FROM scratch

COPY --from=builder /go/bin/app /go/bin/app

EXPOSE 8080
CMD ["/go/bin/app"]