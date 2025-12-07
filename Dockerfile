FROM golang:1.25-bookworm AS builder

WORKDIR /app

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GO111MODULE=on \
    GOFLAGS="-buildvcs=false"

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o server -ldflags="-s -w" .

FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache tzdata ca-certificates

ENV TZ=Asia/Jakarta

COPY --from=builder /app/server /app/server

RUN adduser -D -u 10001 appuser
USER appuser

EXPOSE 8777

CMD ["./server"]
