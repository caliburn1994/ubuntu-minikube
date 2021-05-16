#!/usr/bin/env bash

PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../../.. >/dev/null 2>&1 && pwd)" && . "${PROJECT_ROOT_PATH}/deploy/common.sh"
. "${PROJECT_ROOT_PATH}/deploy/sub/localstack/aws/bashrc_aws.sh" || echo_warn "Failed to import bashrc_aws.sh"

bucket_name=test-bucket

function create_bucket() {
  echo_debug "Creating a bucket..."
  aws s3 mb s3://${bucket_name}
}
function remove_bucket() {
  echo "Removing the bucket..."
  aws s3 rb s3://${bucket_name}
}

function ls_bucket() {
  echo "List all buckets..."
  aws s3 ls --profile=localstack
}
function ls_objects() {
  echo "List all objects..."
  aws s3 ls --profile=localstack s3://${bucket_name}
}

upload_file="s3_test.txt"
function upload_s3() {
  printf "Uploading..., the content of the file is: "
  echo "test" | tee ./${upload_file}

  aws s3 cp ${upload_file} s3://${bucket_name}

  rm ${upload_file}
}

function download_s3() {
  printf "Downloading..."
  aws s3 cp s3://${bucket_name}/${upload_file} ./

  printf "the content of the file is: " && cat $upload_file
  rm ${upload_file}
}

function remove_all_objects() {
  echo "Removing all objects..."
  aws s3 rm s3://${bucket_name} --recursive
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
