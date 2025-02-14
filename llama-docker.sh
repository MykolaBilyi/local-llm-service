#!/usr/bin/env sh

load_vars() {
   export $(grep -v '^#' ${1:-.env} | xargs -n 1)
}

prepare_env_args() {
  local prefix=$1
  env | grep "^${prefix}_" | xargs -r printf "-e %s "
}

if [ -f ".env" ]; then load_vars .env; fi

name=${1:-llamacpp}
shift 1

exec docker run --rm -i \
  --name $name \
  --network models \
  --volume models:/models \
  --gpus all \
  $(prepare_env_args LLAMA_ARG) \
  llama.cpp $@