#!/bin/bash
vagrant ssh -c "docker ps $1 --format 'table {{.Image}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.RunningFor}}\t{{.ID}}'"
