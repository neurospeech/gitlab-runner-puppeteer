#!/bin/sh
gitlab-runner register \
  --name $GITLAB_RUNNER_NAME  
  --non-interactive \
  --executor "docker" \
  --docker-image alpine:latest \
  --url $GITLAB_INSTANCE \
  --registration-token $GITLAB_TOKEN \
  --description "docker-runner" \
  --maintenance-note "Free-form maintainer notes about this runner" \
  --tag-list "docker,aws" \
  --run-untagged="false" \
  --locked="false" \
  --access-level="not_protected"

gitlab-runner
