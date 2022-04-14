<p align="center">
  <img width=65% height=65% src="https://github.com/vincentneo/CoreGPX/raw/master/CoreGPX%20title.png">
</p>
<p align="center">
	<b>
	Parse and generate GPX files easily on iOS, watchOS & macOS.
	</b>
  <br/>
  <a href="https://github.com/vincentneo/CoreGPX/actions">
    <img src="https://github.com/vincentneo/CoreGPX/actions/workflows/swift.yml/badge.svg?branch=master"/>
  </a>
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-5.2-orange.svg"/>
  </a>
	<a href="https://www.topografix.com/gpx/1/1/">
    <img src="https://img.shields.io/badge/gpx-1.1-yellow.svg"/>
  </a>
  <a href="http://doge.mit-license.org">
    <img src="http://img.shields.io/:license-mit-red.svg"/>
  </a>
  <a href="https://cocoapods.org/pods/CoreGPX">
    <img src="https://img.shields.io/cocoapods/p/CoreGPX.svg?style=flat"/>
  </a>
	<br/>
	<a href="https://github.com/apple/swift-package-manager">
    <img src="https://img.shields.io/badge/Swift%20Package%20Manager-Supported-darkgreen.svg"/>
  </a>
	<a href="https://github.com/Carthage/Carthage">
    <img src="https://img.shields.io/badge/Carthage-Supported-darkgreen.svg?style=flat"/>
  </a>
	<a href="https://cocoapods.org/pods/CoreGPX">
    <img src="https://img.shields.io/cocoapods/v/CoreGPX.svg?style=flat"/>
  </a>
</p>

## What is CoreGPX?
CoreGPX is a port of iOS-GPX-Framework to Swift language.

CoreGPX currently supports all GPX tags listed in GPX v1.1 schema, along with the recent addition of GPX v1.0 support. It can generate and parse GPX compliant files on iOS, macOS and watchOS. 

As it makes use of `XMLParser` for parsing GPX files, CoreGPX is fully dependent on the `Foundation` API only.

## Features
- [x] Successfully outputs string that can be packaged into a GPX file
- [x] Parses GPX files using native XMLParser
- [x] Support for iOS, macOS & watchOS
- [x] Supports `Codable` in essential classes
- [x] Enhanced full support for `GPXExtensions` for both parsing and creating. 
- [x] Lossy GPX compression. Check out [GPXCompressor](https://github.com/vincentneo/GPXCompressor) for an implementation of this new feature.
- [x] **(new)** Legacy GPX support. (GPX 1.0 and below)

## Documentation

CoreGPX is documented using [jazzy](https://github.com/realm/jazzy).

[![Documentation Status](https://vincentneo.github.io/CoreGPX/badge.svg)](https://vincentneo.github.io/CoreGPX/index.html)

You can read the documentation [here](https://vincentneo.github.io/CoreGPX/index.html), which documents most of the important features that will be used for parsing and creating of GPX files.

## Installation

CoreGPX supports CocoaPods, Carthage, as well as Swift Package Manager, such that you can install it, any way you want.

To install using [CocoaPods](https://cocoapods.org), simply add the following line to your Podfile:

```ruby
pod 'CoreGPX'
```

CoreGPX works with [Carthage](https://github.com/Carthage/Carthage) as well, simply add the following line to your Cartfile:
```Swift
github "vincentneo/CoreGPX"
```

## How to use?
Check out the [wiki page](https://github.com/vincentneo/CoreGPX/wiki) for some basic walkthroughs of how to use this library.

Alternatively, you may check out the Example app, by cloning the repo, `pod install` and running the Example project.

To know in-depth of how CoreGPX can be used in a true production setting, please refer to awesome projects like [iOS-Open-GPX-Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker) or [Avenue GPX Viewer](https://github.com/vincentneo/Avenue-GPX-Viewer), both of which, uses CoreGPX.

## Extras
Check out the Extras folder for some extra helper codes that may help you with using CoreGPX.
Simply drag and drop it into your project to use.
 - `GPX+CLLocation.swift`: Converting `CLLocation` type to `GPXWaypoint`, `GPXTrackPoint` and more.

## Contributing
Contributions to this project will be more than welcomed. Feel free to add a pull request or open an issue.
If you require a feature that has yet to be available, do open an issue, describing why and what the feature could bring and how it would help you!

## Previous Builds Logs
History of older build logs can be found at Travis CI:
[![Travis CI](https://travis-ci.com/vincentneo/CoreGPX.svg?branch=master)](https://travis-ci.com/vincentneo/CoreGPX)

CoreGPX recently switched to GitHub Actions due to the loss of free tier Travis CI for open sourced Mac-based projects.


## Like the project? Check out these too!
- [iOS-Open-GPX-Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker), an awesome open-sourced GPS tracker for iOS and watchOS.
- [Avenue GPX Viewer](https://github.com/vincentneo/Avenue-GPX-Viewer), a GPX file viewer, written for macOS 10.12 and above.
- [LocaleComplete](https://github.com/vincentneo/LocaleComplete), a small library to make `Locale` identifier hunting more easy and straightforward.

## License
CoreGPX is available under the MIT license. See the LICENSE file for more info. 
