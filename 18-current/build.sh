#!/bin/bash
docker build --pull --force-rm -t azihub/asterisk:18 --file ./build.Dockerfile .