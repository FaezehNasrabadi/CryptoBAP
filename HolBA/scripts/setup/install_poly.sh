#!/usr/bin/env bash

# exit immediately if an error happens
set -e

OPT_DIR_PARAM=$1

# get setup directory path
SETUP_DIR=$(dirname "${BASH_SOURCE[0]}")
SETUP_DIR=$(readlink -f "${SETUP_DIR}")

# find the environment variables
set --
source "${SETUP_DIR}/env_config_gen.sh" "${OPT_DIR_PARAM}"

##################################################################


# based on HOL4 developers/install-poly.sh
# --------------------------------------------
POLY_BASE="https://github.com/polyml/polyml"
POLY_VERSION="v5.8.1"

# if poly version is specified in the environment, use this
if [[ ! -z "${HOLBA_POLYML_VERSION}" ]]; then
  POLY_VERSION=${HOLBA_POLYML_VERSION}
fi

POLY_URL=${POLY_BASE}/archive/${POLY_VERSION}.tar.gz

POLY_DIR=${HOLBA_OPT_DIR}/polyml_${POLY_VERSION}
POLY_DIR_SRC=${HOLBA_OPT_DIR}/polyml_${POLY_VERSION}_src




##################################################################


# if the output directory exists, we already have a polyml in the cache
if [[ -d "${POLY_DIR}" && -x "${POLY_DIR}/bin/poly" ]]; then
  echo "polyml is already available in the cache, exiting."
  exit 0
elif [[ -d "${POLY_DIR}" ]]; then
  echo "cached polyml is incomplete, removing stale directory"
  rm -rf "${POLY_DIR}" "${POLY_DIR_SRC}"
fi

echo "polyml is not in the cache, downloading it now."

# prepare directories
if [[ -d "${POLY_DIR_SRC}" ]]; then
  echo "removing stale PolyML source directory: ${POLY_DIR_SRC}"
  rm -rf "${POLY_DIR_SRC}"
fi
mkdir "${POLY_DIR_SRC}"
mkdir "${POLY_DIR}"

# download polyml
wget -qO- ${POLY_URL} | \
  tar xvz -C "${POLY_DIR_SRC}" --strip-components 1

# compile polyml
cd "${POLY_DIR_SRC}"
echo "*** Configuring PolyML for prefix: ${POLY_DIR}"
./configure --prefix="${POLY_DIR}"
make

# install polyml to prefix dir
make install

# remove source directory
cd "${HOLBA_OPT_DIR}"
rm -rf "${POLY_DIR_SRC}"

