#!/usr/bin/env bash

# Detect build context
if [ -z "$ENV" ]; then
  echo "PR validation build detected"
  export BUILD_TYPE="pr"
else
  echo "Pipeline build detected for environment: $ENV"
  export BUILD_TYPE="pipeline"
fi

echo "Build ID $CODEBUILD_BUILD_ID"
echo "Source Version $CODEBUILD_SOURCE_VERSION"