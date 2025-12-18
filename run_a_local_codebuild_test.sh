#!/usr/bin/env bash

docker pull public.ecr.aws/codebuild/amazonlinux-x86_64-standard:4.0
docker pull public.ecr.aws/codebuild/local-builds:latest

if [ -d localtest_tmp ]
then
  rm -rf localtest_tmp
fi

mkdir localtest_tmp

curl -o localtest_tmp/codebuild_build.sh https://raw.githubusercontent.com/aws/aws-codebuild-docker-images/master/local_builds/codebuild_build.sh
chmod +x localtest_tmp/codebuild_build.sh

# Setup local environment variable file
# Find if there are an AWS session credentials in environment variables and use those in the container
env | grep AWS_ > localtest_tmp/localrun_environment_file
if [ "$AWS_ACCESS_KEY_ID" == "" ]
then
  echo "AWS_ACCESS_KEY_ID=dummy" >> localtest_tmp/localrun_environment_file
  echo "AWS_SECRET_ACCESS_KEY=dummy" >> localtest_tmp/localrun_environment_file
  echo "AWS_DEFAULT_REGION=eu-west-2" >> localtest_tmp/localrun_environment_file
fi

localtest_tmp/codebuild_build.sh -e localtest_tmp/localrun_environment_file -i public.ecr.aws/codebuild/amazonlinux-x86_64-standard:4.0 -a localtest_tmp/
