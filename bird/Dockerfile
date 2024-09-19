FROM golang:1.22.5

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download


COPY . .

EXPOSE 4201

CMD ["go", "run", "main.go"]


