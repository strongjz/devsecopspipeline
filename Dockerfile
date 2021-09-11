FROM golang:1.13-alpine AS builder

RUN apk update && apk add --no-cache git

WORKDIR /go/src/app
COPY . .

RUN GIT_TERMINAL_PROMPT=1 go get -d -v
RUN CGO_ENABLED=0 go build -o /go/bin/app

FROM golang:1.13-alpine

COPY --from=builder /go/bin/app /go/bin/app

EXPOSE 8080
EXPOSE 8090

CMD ["/go/bin/app"]