ARG arch=amd64
ARG goarch=amd64
ARG goos=linux

# ============================================================
# Build container containing our pre-pulled libraries.
# As this changes rarely it means we can use the cache between
# building each microservice.
FROM golang:alpine as build

# The golang alpine image is missing git so ensure we have additional tools
RUN apk add --no-cache \
      curl \
      git \
      tzdata \
      zip

WORKDIR /work
COPY go.mod .
RUN go mod download

# ============================================================
# source container contains the source as it exists within the
# repository.
FROM build as source
WORKDIR /work
ADD . .

# ============================================================
# Run all tests in a new container so any output won't affect
# the final build.
FROM source as test
RUN CGO_ENABLED=0 go test -timeout 60s ./...
#RUN CGO_ENABLED=1 GOMAXPROCS=4 go test -timeout 60s -race ./...

# ============================================================
# Build the specific platform
FROM source as compile
ARG arch
ARG goos
ARG goarch
ARG goarm
ARG branch
ARG buildNumber
ARG version
ARG uploadPath=
ARG uploadCred=
WORKDIR /work

# NB: CGO_ENABLED=0 forces a static build
RUN VERSION="${version}.${branch}.${buildNumber}" &&\
    sed -i "s/\"dev\"/\"${VERSION}/g" version.go &&\
    GOVERSION=$(go version | awk '{print $3}') &&\
    TARGET="statsdaemon-${VERSION}.${goos}-${arch}.${GOVERSION}.${buildNumber}" &&\
    TAR="${TARGET}.tgz" &&\
    mkdir -p build dist &&\
    CGO_ENABLED=0 GOOS=${goos} GOARCH=${goarch} GOARM=${goarm} go build -o build/$TARGET/statsdaemon &&\
    (cd build;tar cvzpf ../dist/${TAR} ${TARGET}) &&\
    if [ -n "${uploadCred}" -a -n "${uploadPath}" ] ;\
    then \
      cd dist; \
      curl -u ${uploadCred} --upload-file ${TAR} ${uploadPath}/; \
    fi
