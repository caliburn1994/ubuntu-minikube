#!/usr/bin/env bash

PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../../.. >/dev/null 2>&1 && pwd)" && . "${PROJECT_ROOT_PATH}/deploy/common.sh"
AWS_ENDPOINT=$(cat "${PROJECT_ROOT_PATH}/out/localstack/expose_ip.txt")
AWS_PROFILE=localstack

# This is a tool
# you can put it in bashrc
function aws() {
  cmd_str=""

  # default optional parameters
  dop=("--profile=${AWS_PROFILE}" "--endpoint-url=${AWS_ENDPOINT}")

  # optional parameters
  for op in "$@"; do
    cmd_str+="$op "

    # if positional parameters exists, default positional parameters will be assigned an empty string
    for ((i = 0; i < ${#dop[@]}; ++i)); do
      IFS="=" read -r para _ <<<"${dop[$i]}"
      if [[ $op =~ ^${para}.* ]]; then
        dop[$i]=""
      fi
    done
  done

  echo_debug "aws $cmd_str" "${dop[@]}"
  eval "/usr/local/bin/aws $cmd_str" "${dop[@]}"
}

# test
# something like `--profile localstack` will not work, you should use `--profile=localstack`
function test_bashrc_aws() {
  bucket_name=test-bucket
  aws s3 mb s3://${bucket_name} --profile=${AWS_PROFILE}
  aws s3 ls --profile=${AWS_PROFILE}
  aws s3 ls
  aws s3 rb s3://${bucket_name} --endpoint-url="${AWS_ENDPOINT}"
}
