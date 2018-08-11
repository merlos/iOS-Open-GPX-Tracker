#!/bin/sh

# Simple script to generate Open GPX Tracker documents
#
# Requires jazzy ( https://github.com/realm/jazzy // [sudo] gem install jazzy)
#
# Usage:
#
#  $ ./gendocs.sh
#
# Settings
#
#
OUTPUT_PATH='../gh-pages/docs/'

jazzy --output=$OUTPUT_PATH --min-acl private
