#!/bin/bash

source futility

rm results.txt

log_result 'before it'

it 'takes a description and a pipe' <(
  sleep 1
  echo_error 'first error inside the pipe'
  init_sec=$(date +%s)
  sleep 1
  log_result "$init_sec |inside the pipe"
  sleep 1
  err_sec=$(date +%s)
  echo_error "$err_sec" 'last error inside the pipe'
  sleep 1
  log_result 'inside pipe'
)

(
log_result 'after it'
)

cat results.txt 

# it 'responds to fail' <(
#   failed
# )

# it 'responds to passed' <(
#   passed
# )

