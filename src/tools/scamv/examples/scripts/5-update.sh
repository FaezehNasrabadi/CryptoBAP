<<<<<<< HEAD
#!/usr/bin/env bash

set -e

# get scamv examples and holba directory path
SCAMV_EXAMPLES_DIR=$(dirname "${BASH_SOURCE[0]}")
SCAMV_EXAMPLES_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/..")
HOLBA_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/../../../..")

# find the environment
source "${HOLBA_DIR}/env.sh"
echo "============================"

# update HOLBA
cd "${HOLBA_DIR}"
git pull
make main

<<<<<<< HEAD
# update EmbExp-Box
cd "${HOLBA_EMBEXP_DIR}/EmbExp-Box"
git pull


=======
# update EmbExp-Logs
cd "${HOLBA_EMBEXP_LOGS}"
git pull

# update EmbExp-Box
cd "${HOLBA_EMBEXP_DIR}/EmbExp-Box"
git pull
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
||||||| empty tree
=======
#!/usr/bin/env bash

set -e

# get scamv examples and holba directory path
SCAMV_EXAMPLES_DIR=$(dirname "${BASH_SOURCE[0]}")
SCAMV_EXAMPLES_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/..")
HOLBA_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/../../../..")

# find the environment
source "${HOLBA_DIR}/env.sh"
echo "============================"

# update HOLBA
cd "${HOLBA_DIR}"
git pull
make main

# update EmbExp-Logs
cd "${HOLBA_EMBEXP_LOGS}"
git pull

# update EmbExp-Box
cd "${HOLBA_EMBEXP_DIR}/EmbExp-Box"
git pull
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
