#!/usr/bin/env bash

set -e

# Login into docker
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

architectures="arm arm64 amd64"
images=""
platforms=""

for arch in $architectures
do
# Build for all architectures and push manifest
  platforms="linux/$arch,$platforms"
done

platforms=${platforms::-1}


# Push multi-arch image
buildctl build --frontend dockerfile.v0 \
      --local dockerfile=. \
      --local context=./src/ \
      --exporter image \
      --exporter-opt name=$DOCKER_IMAGE:latest \
      --exporter-opt push=true \
      --frontend-opt platform=$platforms \
      --frontend-opt filename=./src/Dockerfile

# Push image for every arch with arch prefix in tag
for arch in $architectures
do
# Build for all architectures and push manifest
  buildctl build --frontend dockerfile.v0 \
      --local dockerfile=. \
      --local context=./src/ \
      --exporter image \
      --exporter-opt name=$DOCKER_IMAGE:latest-$arch \
      --exporter-opt push=true \
      --frontend-opt platform=linux/$arch \
      --frontend-opt filename=./src/Dockerfile &
done

wait

docker pull $DOCKER_IMAGE:latest-arm
docker tag $DOCKER_IMAGE:latest-arm $DOCKER_IMAGE:latest-armhf
docker push $DOCKER_IMAGE:latest-armhf
