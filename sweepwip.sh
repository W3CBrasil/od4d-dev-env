#!/usr/bin/env bash

# The MIT License (MIT)
# 
# Copyright (c) 2014 Marco Aurelio Valtas Cunha
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# TODOS:
# check branches for wip?

DEFAULT_PROJECT_DIR=${SWEEPWIP_DIR:-${HOME}/Projects}
PROJECTS_DIR=${DEFAULT_PROJECT_DIR}

usage() {
  [[ -n ${1} ]] && echo -e "** ${1}\n"
  cat <<EOU
Scans directories for '.git' and outputs the state of the local git repository.

Usage $(basename $0) [ -h|--help ] [ -d DIR_TO_SCAN ] [ -abflMPRu ]

DIR_TO_SCAN     Directory where find projects  managed by git, currently it
                defaults to "${DEFAULT_PROJECT_DIR}", you can change it by
                setting the environment variable SWEEPWIP_DIR or using
                the option -d.

Uppercase options like -M will supress behavior that is eneable by default,
lowercase options do the oposite.

-h|--help       This message
-a              Shows log messages of commits ahead
-b              Shows log messages of commits behind
-d DIR          Directory to scan for repositories, it superseeds SWEEPWIP_DIR
                environment variable.
-f              Perform 'git fetch'
-l              List details of local changes
-M              Supress local changes check, this will supress -l
-P              Supress local push/pull differences
-R              Supress check for remotes
-u              Try fast-forward changes (git merge --ff-only)

EOU
 exit
}

# be compatible with GNU help style.
[[ ${1} == "--help" ]] && usage

# try to be backward compatible with old straight directory
# argument "sweepwip directory/", emit message, re-invoke
# with "-d" and quit the wrong invocation.
[[ -d "${1}" ]] \
  && (tput setaf 1; echo -e "*** Deprecated usage, please use -d. See --help"; tput sgr0;) \
  && (${0} -d ${@}) \
  && exit

# except 'h' here and 'p' in check_project, these
# options need to be the same
while getopts “hd:fMPRluab” OPTION; do
  case $OPTION in
    h) usage;;
    d) PROJECTS_DIR=${OPTARG};;
   \?) usage;;
  esac
done

check_project() {
  # Options...
  LIST_COMMITS_AHEAD=
  LIST_COMMITS_BEHIND=
  PERFORM_GIT_FETCH=
  LIST_LOCAL_CHANGES=
  FAST_FORWARD_CHANGES=
  LOCAL_CHANGES=true
  CHANGES_NOT_PUSHED=true
  REMOTE_NOT_DEFINED=true

  function _flip_option() { [[ ${1} == 'true' ]] && echo '' || echo 'true'; }

  while getopts “p:d:fMPRluab” OPTION; do
    case $OPTION in
      d) PROJECTS_DIR=${OPTARG};;
      p) PROJECT=${OPTARG};;
      f) PERFORM_GIT_FETCH=$(_flip_option ${PERFORM_GIT_FETCH});;
      M) LOCAL_CHANGES=$(_flip_option ${LOCAL_CHANGES});;
      l) LIST_LOCAL_CHANGES=$(_flip_option ${LIST_LOCAL_CHANGES});;
      P) CHANGES_NOT_PUSHED=$(_flip_option ${CHANGES_NOT_PUSHED});;
      R) REMOTE_NOT_DEFINED=$(_flip_option ${REMOTE_NOT_DEFINED});;
      u) FAST_FORWARD_CHANGES=$(_flip_option ${FAST_FORWARD_CHANGES});;
      a) LIST_COMMITS_AHEAD=$(_flip_option ${LIST_COMMITS_AHEAD});;
      b) LIST_COMMITS_BEHIND=$(_flip_option ${LIST_COMMITS_BEHIND});;
    esac
  done

  function _colored()  { tput setaf ${1}; echo -e ${2}; tput sgr0; }
  function in_red()    { _colored 1 "${1}"; }
  function in_green()  { _colored 2 "${1}"; }
  function in_yellow() { _colored 3 "${1}"; }
  function in_cyan()   { _colored 6 "${1}"; }

  [[ ! -d ${PROJECTS_DIR} ]] && in_red "error parsing options, use --help" && exit 1

  local search_dir=${PROJECTS_DIR}  # the root from where we start our search
  local project_dir=${PROJECT%.git} # the dir found with .git striped

  function proj_name() {
    local name=${project_dir#${search_dir}}

    # restore name if search_dir is the same as the project_dir
    [[ ${name} == "/" ]] && name=${search_dir}

    name=${name#/} # remove leading '/'
    name=${name%/} # remove trailing '/'
    echo $(basename ${name})
  }

  function dirty_git_status() {
    local status=$(git status -s)
    if [[ ${status} != "" ]]; then
      in_yellow "LOCAL CHANGES NOT COMMITED"
      while read line; do
        [[ -n ${LIST_LOCAL_CHANGES} ]] && echo -e "\t${line}"
      done <<<"${status}"
    fi
  }

  function git_changes_not_pushed() {
    local status=$(git status -sb)
    local re='ahead ([0-9]+)'
    if [[ ${status} =~ ${re} ]]; then
      in_red "COMMITS AHEAD: ${BASH_REMATCH[1]}"
      [[ -n ${LIST_COMMITS_AHEAD} ]] && \
        git log --format=oneline --abbrev-commit origin/master..master \
        | while read line; do echo -e "\t${line}"; done
    fi
    re='behind ([0-9]+)'
    if [[ ${status} =~ ${re} ]]; then
      in_cyan "COMMITS BEHIND: ${BASH_REMATCH[1]}"
      [[ -n ${LIST_COMMITS_BEHIND} ]] && \
        git log --format=oneline --abbrev-commit master..origin/master \
        | while read line; do echo -e "\t${line}"; done
    fi
  }

  function git_remote_defined() {
    if [[ $(git remote) == "" ]]; then
      in_red "NO REMOTES DEFINED"
    fi
  }

  # main execution
  local project_name=$(proj_name)
  in_green ">>> ${project_name} <<<"
  (cd ${project_dir}
    [[ -n ${PERFORM_GIT_FETCH} ]]    && git fetch -q
    [[ -n ${FAST_FORWARD_CHANGES} ]] && git merge --ff-only
    [[ -n ${CHANGES_NOT_PUSHED} ]]   && git_changes_not_pushed
    [[ -n ${LOCAL_CHANGES} ]]        && dirty_git_status
    [[ -n ${REMOTE_NOT_DEFINED} ]]   && git_remote_defined
  )
}

export -f check_project # make this available for find

find -L "${PROJECTS_DIR}"  -type d -name '.git' -exec bash -c "check_project $* -d ${PROJECTS_DIR} -p '{}' " \;
