#!/bin/bash

# Help menu
print_help() {
cat <<-HELP
This script is used to fix the file permissions of a Drupal platform. You need
to provide the following argument:

  --root: Path to the root of your Drupal installation.

Usage: (sudo) ${0##*/} --root=PATH
Example: (sudo) ${0##*/} --drupal_path=/var/aegir/platforms/drupal-7.50
HELP
exit 0
}

if [ $(id -u) != 0 ]; then
  printf "Error: You must run this with sudo or root.\n"
  exit 1
fi

drupal_root=${1%/}

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root=*)
        drupal_root="${1#*=}"
        ;;
    --help) print_help;;
    *)
      printf "Error: Invalid argument, run --help for valid arguments.\n"
      exit 1
  esac
  shift
done

if [ -z "${drupal_root}" ] \
  || [ ! -d "${drupal_root}/sites" ] \
  || [ ! -f "${drupal_root}/core/modules/system/system.module" ] \
  && [ ! -f "${drupal_root}/modules/system/system.module" ]; then
    printf "Error: Please provide a valid Drupal root directory.\n"
    exit 1
fi

cd ${drupal_root}

printf "Setting main permissions inside "${drupal_root}"...\n"
mkdir -p ${drupal_root}/sites/all/{modules,themes,libraries,drush}
chmod 0751 ${drupal_root}/sites
chmod 0755 ${drupal_root}/sites/*
chmod 0644 ${drupal_root}/sites/*.php
chmod 0644 ${drupal_root}/sites/*.txt
chmod 0755 ${drupal_root}/sites/all/drush

printf "Setting permissions of all codebase directories inside "${drupal_root}"...\n"
find ${drupal_root}/sites/all/{modules,themes,libraries} -type d -exec \
  chmod 02775 {} \;

printf "Setting permissions of all codebase files inside "${drupal_root}"...\n"
find ${drupal_root}/sites/all/{modules,themes,libraries} -type f -exec \
  chmod 0664 {} \;

### known exceptions
chmod -R 775 ${drupal_root}/sites/all/libraries/tcpdf/cache &> /dev/null

echo "Done setting proper permissions on platform files and directories."
