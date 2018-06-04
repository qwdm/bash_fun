#!/bin/bash
for pid in `ps | grep 'cat\|nc\|sleep' | awk '{print $1}'`; do kill $pid; done
