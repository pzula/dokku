#!/usr/bin/env bats

load test_helper

setup() {
  create_app
}

teardown() {
  destroy_app
}

@test "(build-env) special characters" {
  run dokku config:set --no-restart $TEST_APP NEWRELIC_APP_NAME="$TEST_APP (Staging)"
  echo "output: "$output
  echo "status: "$status
  assert_success

  deploy_app
  run dokku config $TEST_APP
  assert_success
}

@test "(build-env) default curl timeouts" {
  run dokku config:unset --global CURL_CONNECT_TIMEOUT
  echo "output: "$output
  echo "status: "$status
  assert_success

  run dokku config:unset --global CURL_TIMEOUT
  echo "output: "$output
  echo "status: "$status
  assert_success

  deploy_app
  run /bin/bash -c "dokku config:get --global CURL_CONNECT_TIMEOUT | grep 5"
  echo "output: "$output
  echo "status: "$status
  assert_success

  run /bin/bash -c "dokku config:get --global CURL_TIMEOUT | grep 30"
  echo "output: "$output
  echo "status: "$status
  assert_success
}

@test "(build-env) buildpack failure" {
  run dokku config:set --no-restart $TEST_APP BUILDPACK_URL='https://github.com/dokku/fake-buildpack'
  echo "output: "$output
  echo "status: "$status
  assert_success

  run deploy_app
  echo "output: "$output
  echo "status: "$status
  assert_failure
}
