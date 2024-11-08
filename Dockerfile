# Build the manager binary
FROM --platform=$BUILDPLATFORM golang:1.20.5 AS builder

WORKDIR /workspace

# Copy go.mod and go.sum together and download dependencies only once
COPY go.mod go.sum ./
RUN GOPROXY=direct go mod download

# Copy the Go source code
COPY cmd/aws-application-networking-k8s/main.go main.go
COPY pkg/ pkg/
COPY scripts/ scripts/

# Build the binary with static linking for target OS and architecture
RUN CGO_ENABLED=0 GOOS=$(echo $TARGETOS) GOARCH=$(echo $TARGETARCH) go build -a -o /manager main.go

# Use a minimal base image
FROM --platform=$TARGETPLATFORM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /manager /manager

USER 65532:65532

ENTRYPOINT ["/manager"]
