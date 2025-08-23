#!/usr/bin/env bash

set -eou pipefail

if [ "$TAG" = "" ]; then
  TAG=$(echo "${GITHUB_REF#refs/heads/}" | sed 's/[^a-zA-Z0-9._-]//g' | awk '{print substr($0, length($0)-120)}')
  if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
    TAG=$(echo "${GITHUB_REF#refs/tags/}" | sed 's/[^a-zA-Z0-9._-]//g' | awk '{print substr($0, length($0)-120)}')
  fi
fi

PLATFORM="amd64"
if [ "$RUNNER_ARCH" = "ARM64" ]; then
  PLATFORM="arm64"
fi

DOCKER_IMAGE_CACHE="ghcr.io/${GITHUB_REPOSITORY}"
if [ "${DOCKER_CONTEXT}" != "." ]; then
  DOCKER_IMAGE_CACHE="${DOCKER_IMAGE_CACHE}/${DOCKER_CONTEXT//[^A-Za-z-]/}"
fi

if [ "${DOCKER_IMAGE}" = "GHCR" ]; then
  DOCKER_IMAGE="$DOCKER_IMAGE_CACHE"
elif [ "${DOCKER_IMAGE}" = "" ]; then
  DOCKER_IMAGE="us-docker.pkg.dev/${GCLOUD_PROJECT}/shared/${GITHUB_REPOSITORY##*/}"
else
  DOCKER_IMAGE="us-docker.pkg.dev/${GCLOUD_PROJECT}/${DOCKER_IMAGE}"
fi

CACHE_TO=""
if [ "${TAG}" = "main" ]; then
  CACHE_TO="type=registry,ref=${DOCKER_IMAGE_CACHE}:cache-$PLATFORM,mode=max"
fi

CACHE_FROM="type=registry,ref=${DOCKER_IMAGE_CACHE}:cache-$PLATFORM"

{
  echo "image=$DOCKER_IMAGE"
  echo "platform=$PLATFORM"
  echo "tag=$TAG"
  echo "cache-to=$CACHE_TO"
  echo "cache-from=$CACHE_FROM"
} >> "$GITHUB_OUTPUT"
