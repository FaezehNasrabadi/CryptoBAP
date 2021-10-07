<<<<<<< HEAD
#!/usr/bin/env bash

set -e

<<<<<<< HEAD
ARCH_EXPTYPE_PARAM=$1
=======
BOARD_TYPE=$1
LISTNAME_PARAM=$2
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

# get scamv examples and holba directory path
SCAMV_EXAMPLES_DIR=$(dirname "${BASH_SOURCE[0]}")
SCAMV_EXAMPLES_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/..")
HOLBA_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/../../../..")

<<<<<<< HEAD
# check inputs
if [[ -z "${ARCH_EXPTYPE_PARAM}" ]]; then
  echo "ERROR: please provide experiment architecture and type as parameter (e.g. arm8/exps2)"
  exit 1
=======
# prepare options listname and board_type
if [[ ! -z "${LISTNAME_PARAM}" ]]; then
  LISTNAME_OPTION="--listname ${LISTNAME_PARAM}"
else
  LISTNAME_OPTION=
fi
if [[ ! -z "${BOARD_TYPE}" ]]; then
  BOARD_TYPE_OPTION="--board_type ${BOARD_TYPE}"
else
  BOARD_TYPE_OPTION=
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
fi

# find the environment
source "${HOLBA_DIR}/env.sh"
echo "============================"

# create EmbExp-ProgPlatform working directory
export EMBEXP_PROGPLATFORM=${SCAMV_EXAMPLES_DIR}/tempdir/EmbExp-ProgPlatform
mkdir -p "${EMBEXP_PROGPLATFORM}"
rm -rf "${EMBEXP_PROGPLATFORM}"
git clone https://github.com/kth-step/EmbExp-ProgPlatform.git "${EMBEXP_PROGPLATFORM}"
cd "${EMBEXP_PROGPLATFORM}"
<<<<<<< HEAD
git checkout scamv

# in the logs directory ...
cd "${HOLBA_EMBEXP_LOGS}"
# find the exp classes,
EXPSDIR=${HOLBA_EMBEXP_LOGS}/${ARCH_EXPTYPE_PARAM}
for dir in "${EXPSDIR}"/*/
do
  dir=${dir%*/}
  dir=${dir##*/}

  # and start the experiments
  ./scripts/run_batch.py --exp_class "${ARCH_EXPTYPE_PARAM}/${dir}"
done

=======
git checkout $BRANCH

# in the logs directory ...
cd "${HOLBA_EMBEXP_LOGS}"

# and start the experiments
./scripts/run_batch.py ${LISTNAME_OPTION} ${BOARD_TYPE_OPTION}
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

||||||| empty tree
=======
#!/usr/bin/env bash

set -e

BOARD_TYPE=$1
LISTNAME_PARAM=$2

# get scamv examples and holba directory path
SCAMV_EXAMPLES_DIR=$(dirname "${BASH_SOURCE[0]}")
SCAMV_EXAMPLES_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/..")
HOLBA_DIR=$(readlink -f "${SCAMV_EXAMPLES_DIR}/../../../..")

# prepare options listname and board_type
if [[ ! -z "${LISTNAME_PARAM}" ]]; then
  LISTNAME_OPTION="--listname ${LISTNAME_PARAM}"
else
  LISTNAME_OPTION=
fi
if [[ ! -z "${BOARD_TYPE}" ]]; then
  BOARD_TYPE_OPTION="--board_type ${BOARD_TYPE}"
else
  BOARD_TYPE_OPTION=
fi

# find the environment
source "${HOLBA_DIR}/env.sh"
echo "============================"

# create EmbExp-ProgPlatform working directory
export EMBEXP_PROGPLATFORM=${SCAMV_EXAMPLES_DIR}/tempdir/EmbExp-ProgPlatform
mkdir -p "${EMBEXP_PROGPLATFORM}"
rm -rf "${EMBEXP_PROGPLATFORM}"
git clone https://github.com/kth-step/EmbExp-ProgPlatform.git "${EMBEXP_PROGPLATFORM}"
cd "${EMBEXP_PROGPLATFORM}"
git checkout $BRANCH

# in the logs directory ...
cd "${HOLBA_EMBEXP_LOGS}"

# and start the experiments
./scripts/run_batch.py ${LISTNAME_OPTION} ${BOARD_TYPE_OPTION}

>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
