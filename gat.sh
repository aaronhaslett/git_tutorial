#!/bin/bash

GET_COMMITS="ls .gat | grep commit_ | sort -n";
GAT_DIR="./.gat";
GAT_TMP="$GAT_DIR/temp";

_play_to() {
  echo > $GAT_TMP;
  for f in `eval $GET_COMMITS`; do
    patch -s $GAT_TMP $GAT_DIR/$f;
    if [ "$1" != "" ] && [ $f == $1 ]; then break; fi
  done;
};

commit() {
  if [ $# -ne 0 ]; then
    echo "commit takes 0 args";
    exit 1;
  fi;

  if [ ! -d "$GAT_DIR" ]; then
    mkdir $GAT_DIR;
  fi;

  _play_to;

  num_commits=`ls .gat | grep commit_ | wc -l`;
  fn=$GAT_DIR/commit_$num_commits;
  diff $GAT_TMP file > $fn;
  if [ ! -s $fn ]; then
    rm $fn;
  fi;
};

checkout() {
  if [ $# -ne 1 ] || [ ! -f .gat/$1 ]; then
    echo "commit takes 1 arg and it must be a commit name";
    exit 1;
  fi;

  _play_to $1;
  mv $GAT_TMP ./file
};

log() {
  for f in `eval $GET_COMMITS`; do
    echo $f:;
    cat $GAT_DIR/$f;
  done;
};

# If the cmd name doesn't start with _ (internal prefix) and is defined in this file
# then run it with args
if [[ "$1" != _* ]] && declare -F | grep -qw "declare -f $1"; then
  cmd=$1;
  shift;
  $cmd $@;
else
  echo "$1 is not a gat command";
  exit 1;
fi;
