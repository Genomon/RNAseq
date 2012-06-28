#! /bin/bash
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

check_mkdir() {

if [ -d $1 ]; then
  echo "$1 exists."
else
  echo "$1 does not exits."
  mkdir -p $1
fi
}


check_error() {

if [ $1 -ne 0 ]; then
  echo "FATAL ERROR: pipeline script"
  echo "ERROR CODE: $1"
  exit $1
fi
}


is_file_exists() {

if [ -f $1 ]; then
  echo "$1 exists."
  return 0
fi
echo "$1 does not exists."
return 1
}


check_file_exists() {

if [ -f $1 ]; then
  echo "$1 exists."
  return
fi
echo "$1 does not exists."
exit 1
}

check_num_args() {

if [ $1 -ne $2 ]; then
  echo "wrong number of arguments"
  exit 1
fi
}
