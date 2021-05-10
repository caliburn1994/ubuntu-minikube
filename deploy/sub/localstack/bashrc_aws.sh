#!/usr/bin/env bash
# you can put it in bashrc
function aws() {
  cmd_str=""

  # default optional parameters
  dop=("--profile=localstack" "--endpoint-url=http://192.168.0.156:31566")

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

  echo "/usr/local/bin/aws $cmd_str " "${dop[@]}"
  eval "/usr/local/bin/aws $cmd_str " "${dop[@]}"
}

# test
# something like `--profile localstack` will not work, you should use `--profile=localstack`
bucket_name=test-bucket
aws s3 mb s3://${bucket_name} --profile=localstack
aws s3 ls --profile=localstack
aws s3 ls
aws s3 rb s3://${bucket_name} --endpoint-url=http://192.168.0.156:31566
