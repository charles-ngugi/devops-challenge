#Define go version
FROM golang:1.22.5

#set directory
WORKDIR /app

#copy modules
COPY go.mod ./

#download required dependencies
RUN go mod download

#copy rest of files in birdImage dir
COPY . .

#use defined port
EXPOSE 4200

#run the app
CMD [ "go", "run", "main.go" ]

