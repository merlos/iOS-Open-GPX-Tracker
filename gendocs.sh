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
# xcodebuild clean build -workspace OpenGpxTracker.xcworkspace -scheme OpenGpxTracker-Watch

OUTPUT_PATH='../gh-pages/docs/'
jazzy --output=$OUTPUT_PATH --min-acl private -x clean,build,-workspace,OpenGpxTracker.xcworkspace,-scheme,OpenGpxTracker
#jazzy --output=$OUTPUT_PATH --min-acl private
