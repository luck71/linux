#!/bin/bash

SCRIPT_REL_PATH=$(dirname "$0")
export SCRIPT_ABS_PATH=$(realpath ${SCRIPT_REL_PATH})


if [ -f ${SCRIPT_ABS_PATH}/../.pre-commit-config.yaml ]; then
  echo ".pre-commit-config.yaml already exsit, run pre-commit install if needed"
else
  cp ${SCRIPT_ABS_PATH}/pre-commit/pre-commit-config.yaml ${SCRIPT_ABS_PATH}/../.pre-commit-config.yaml
fi

cd ${SCRIPT_ABS_PATH}
python3.9 -m pre_commit install



# ${SCRIPT_ABS_PATH}
