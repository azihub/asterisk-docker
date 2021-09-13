#!/bin/bash
docker run -ti --rm -v ${PWD}/docker-entrypoint.sh:/docker-entrypoint.sh -v ${PWD}/configs/:/etc/asterisk azihub/asterisk:18 /bin/bash