#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../../.. >/dev/null 2>&1 && pwd)"
# dependencies
. "${PROJECT_ROOT_PATH}/deploy/common.sh"

# variables
export AWS_PROFILE=localstack
url="http://$(sudo minikube ip):31566"
bucket_name=test-bucket

function create_bucket() {
  echo_debug "Creating a bucket"
  aws s3 mb s3://${bucket_name} \
    --endpoint-url="${url}"
}
function remove_bucket() {
  echo_debug "removing the bucket"
  aws s3 rb s3://${bucket_name} \
    --endpoint-url="${url}"
}

function ls_bucket() {
  echo_debug "List all buckets"
  aws s3 ls --profile=localstack \
    --endpoint-url="${url}"
}
function ls_objects() {
  echo_debug "List all objects"
  aws s3 ls --profile=localstack s3://${bucket_name} \
    --endpoint-url="${url}"
}

upload_file="s3_test.txt"
function upload_s3() {
  echo_debug "Uploading"
  echo "test" | tee ./${upload_file}

  aws s3 cp ${upload_file} s3://${bucket_name} \
    --endpoint-url="${url}"

  rm ${upload_file}
}
function download_s3() {
  echo_debug "Downloading"
  aws s3 cp s3://${bucket_name}/${upload_file} ./ \
    --endpoint-url="${url}"

  cat ${upload_file}
  rm ${upload_file}
}
function remove_all_objects() {
  echo_debug "removing all objects"
  aws s3 rm s3://${bucket_name} --recursive \
    --endpoint-url="${url}"
}

echo_running
create_bucket
ls_bucket
upload_s3
ls_objects
download_s3
remove_all_objects
remove_bucket
ls_bucket