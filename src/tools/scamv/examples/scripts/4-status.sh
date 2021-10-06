#!/usr/bin/env bash

set -e

<<<<<<< HEAD
=======
EXTRA_OPTIONS=${@:1}

>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
# get scamv examples and holba directory path
SCAMV_EXAMPLES_DIR=$(dirname "${BASH_SOURCE[0]}")
SCAMV_EXAMPLES_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/..")
HOLBA_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/../../../..")

# find the environment
source "${HOLBA_DIR}/env.sh"
echo "============================"

# in the logs directory, call the status script
cd "${HOLBA_EMBEXP_LOGS}"
<<<<<<< HEAD
./scripts/status.py
=======
./scripts/status.py -ps ${EXTRA_OPTIONS}
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

