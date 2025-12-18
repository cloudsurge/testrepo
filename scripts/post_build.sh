#!/usr/bin/env bash

echo "Build completed successfully"

if [ "$BUILD_TYPE" = "pipeline" ] && [ -f "tfplan-$ENV" ]; then
  echo "Terraform plan saved for $ENV environment"
fi