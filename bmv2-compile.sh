#!/usr/bin/env bash

set -e

PROFILE=$1
OTHER_FLAGS=$2

SRC_DIR="$( cd "$( dirname "${PROFILE[0]}" )" >/dev/null 2>&1 && pwd )"


OUT_DIR=${SRC_DIR}/p4c-out/bmv2
FILE=$(basename "$PROFILE")

#echo "SRC_DIR: ${SRC_DIR}"
#echo "OUT_DIR: ${OUT_DIR}"
#echo "FILE: ${FILE}"

mkdir -p ${OUT_DIR}

echo
echo "## Compiling profile ${PROFILE} in ${OUT_DIR}..."

dockerImage=opennetworking/p4c:stable
dockerRun="docker run --rm -w ${SRC_DIR} -v ${SRC_DIR}:${SRC_DIR} -v ${OUT_DIR}:${OUT_DIR} ${dockerImage}"
echo

# Generate preprocessed P4 source (for debugging).
(set -x; ${dockerRun} p4c-bm2-ss --arch v1model \
        ${OTHER_FLAGS} \
        --pp ${OUT_DIR}/${FILE}_pp.p4 ${FILE}.p4)

# Generate BMv2 JSON and P4Info.
(set -x; ${dockerRun} p4c-bm2-ss --arch v1model -o ${OUT_DIR}/${FILE}.json \
        ${OTHER_FLAGS} \
        --p4runtime-files ${OUT_DIR}/${FILE}_p4info.txt ${FILE}.p4)
