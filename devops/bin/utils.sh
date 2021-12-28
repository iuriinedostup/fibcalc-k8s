#!/bin/bash
#
# Bash Utility Functions

msg.die() { >&2 echo "$1" && exit 1; }
msg.done() { echo -e " \033[32mdone\033[0m"; }
msg.task() { echo -n "$1 ..."; }
