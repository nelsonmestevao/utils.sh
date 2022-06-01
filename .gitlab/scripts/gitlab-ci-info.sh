#!/usr/bin/env bash

echo "Gitlab CI/CD info"
echo
echo "started on $(date)"
echo "Project name: $CI_PROJECT_NAME"
echo "Commit SHA: $CI_COMMIT_SHORT_SHA"
echo "On runner: $HOSTNAME with ID: $CI_RUNNER_ID"
echo "Job info url: $CI_JOB_URL"
echo "By user: $GITLAB_USER_LOGIN <$GITLAB_USER_EMAIL>"
echo "Commit: $CI_COMMIT_TITLE"
echo
