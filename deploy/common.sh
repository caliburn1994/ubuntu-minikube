#!/usr/bin/env bash

red=$(tput setaf 1)
green=$(tput setaf 2)
pink=$(tput setaf 13)
reset=$(tput sgr0)

function echo_warn() {
  echo "${red}${1}${reset}"
}

function echo_info() {
  echo "${green}${1}${reset}"
}

function echo_debug() {
  echo "${pink}${1}${reset}"
}