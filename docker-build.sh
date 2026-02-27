#!/bin/bash
set -e

REGISTRY="ghcr.io/inbox-team"
IMAGE_NAME="ib-chatwoot"
TAG="${TAG:-latest}"
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${TAG}"

echo "Building Chatwoot Docker image for AMD64 architecture..."
echo "Target: ${FULL_IMAGE}"
echo "⏰ This will take 15-30 minutes on first build..."
echo ""

# Build the image for amd64 only with BuildKit for better caching
DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -f docker/Dockerfile -t "${FULL_IMAGE}" --build-arg RAILS_ENV=production --build-arg BUNDLE_WITHOUT="development:test" --build-arg RAILS_SERVE_STATIC_FILES=true --progress=plain .

echo ""
echo "✅ Build completed successfully!"
echo "Image: ${FULL_IMAGE}"
echo ""
echo "Pushing to registry..."

docker push "${FULL_IMAGE}"

echo ""
echo "✅ Push completed successfully!"
echo ""
echo "Image pushed to: ${FULL_IMAGE}"
echo ""
echo "To pull and run the image:"
echo "  docker pull ${FULL_IMAGE}"
echo "  docker run -p 3000:3000 ${FULL_IMAGE}"