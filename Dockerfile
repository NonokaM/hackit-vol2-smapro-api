FROM golang:1.21 as build
WORKDIR /hackit
# Copy dependencies list
COPY go.mod go.sum ./
# Build with optional lambda.norpc tag
COPY cmd/main.go .
RUN go build -tags lambda.norpc -o main main.go
# Copy artifacts to a clean image
FROM public.ecr.aws/lambda/provided:al2023
COPY --from=build /hackit/main ./main
ENTRYPOINT [ "./main" ]
