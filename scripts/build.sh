#!/usr/bin/env bash

echo "=====> Printing env"
env

# Initialize Terraform
echo "=====> Initializing Terraform..."
terraform init

# Run Terraform Plan
if [ "$BUILD_TYPE" = "pr" ]; then
  echo ""
  echo "=====> Running scan of infra"
  checkov --framework terraform --directory .
  echo ""
  echo "=====> Running terraform validate"
  terraform validate
  echo ""
  echo "====> Running terraform plan for PR validation..."
  terraform plan -out=tfplan
  PLAN_EXIT_CODE=$?

  # Report status to GitHub
  if [ -n "$GITHUB_TOKEN" ] && [ -n "$CODEBUILD_SOURCE_VERSION" ]; then
    if [ $PLAN_EXIT_CODE -eq 0 ]; then
      STATUS="success"
      DESCRIPTION="=====> Terraform plan succeeded"
    else
      STATUS="failure"
      DESCRIPTION="=====> Terraform plan failed"
    fi

    # Extract PR number if available (format: pr/123)
    if [[ "$CODEBUILD_SOURCE_VERSION" == pr/* ]]; then
      PR_NUMBER=$(echo $CODEBUILD_SOURCE_VERSION | sed 's/pr\///')
      echo "=====> Reporting status for PR #$PR_NUMBER"
    fi

    # Get commit SHA from source
    COMMIT_SHA="${CODEBUILD_RESOLVED_SOURCE_VERSION:-$CODEBUILD_SOURCE_VERSION}"
  fi

  # Exit with plan result
  exit $PLAN_EXIT_CODE

elif [ "$BUILD_TYPE" = "pipeline" ]; then
  echo "=====> Running terraform plan for $ENV environment..."

  # Select or create workspace for environment
  terraform workspace select $ENV 2>/dev/null || terraform workspace new $ENV
  terraform workspace show

  # Run plan
  terraform plan -out=tfplan-$ENV
  PLAN_EXIT_CODE=$?

  if [ $PLAN_EXIT_CODE -ne 0 ]; then
    echo "=====> Terraform plan failed"
    exit $PLAN_EXIT_CODE
  fi

  # Check if we should apply
  # In CodePipeline, apply stages will have different context
  # For now, we'll check if TF_ACTION is set, or use a different method
  # You may need to adjust this based on your CodePipeline configuration

  # Option 1: Check for apply marker (if previous stage creates it)
  if [ -f ".terraform-apply" ] || [ "${TF_ACTION:-}" = "apply" ]; then
    echo "=====> Running terraform apply for $ENV environment..."
    terraform apply -auto-approve tfplan-$ENV
    APPLY_EXIT_CODE=$?

    if [ $APPLY_EXIT_CODE -ne 0 ]; then
      echo "=====> Terraform apply failed"
      exit $APPLY_EXIT_CODE
    fi

    echo "=====> Successfully applied Terraform changes to $ENV environment"
  else
    echo "=====> Plan stage complete. Apply will run in next stage."
  fi
fi