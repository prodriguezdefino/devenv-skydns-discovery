#!/bin/bash
echo "executing: docker run $1"
vagrant ssh -c "docker run $1"
