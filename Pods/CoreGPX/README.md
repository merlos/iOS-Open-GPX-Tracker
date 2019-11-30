<p align="center">
  <img width=65% height=65% src="https://github.com/vincentneo/CoreGPX/raw/master/CoreGPX%20title.png">
</p>
<p align="center">
	<b>
	Parse and generate GPX files easily on iOS, watchOS & macOS.
	</b>
</p>

[![CI Status](https://travis-ci.com/vincentneo/CoreGPX.svg?branch=master)](https://travis-ci.com/vincentneo/CoreGPX)
[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org/blog/swift-5-released/)
[![GPX Version](https://img.shields.io/badge/gpx-1.1-yellow.svg)](https://www.topografix.com/gpx/1/1/)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)
[![Platform](https://img.shields.io/cocoapods/p/CoreGPX.svg?style=flat)](https://cocoapods.org/pods/CoreGPX)
[![Version](https://img.shields.io/cocoapods/v/CoreGPX.svg?style=flat)](https://cocoapods.org/pods/CoreGPX)
[![Carthage compatible](https://img.shields.io/badge/Carthage-✔-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-✔-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## What is CoreGPX?
CoreGPX is a port of iOS-GPX-Framework to Swift language.

CoreGPX currently supports all GPX tags listed in GPX v1.1 schema. It can generate and parse GPX v1.1 compliant files on iOS, macOS and watchOS. 

As it makes use of `XMLParser` for parsing GPX files, CoreGPX is fully dependent on the `Foundation` API only.

## Features
- [x] Successfully outputs string that can be packaged into a GPX file
- [x] Parses GPX files using native XMLParser
- [x] Support for iOS, macOS & watchOS
- [x] **(new)** Supports `Codable` in essential classes
- [x] **(new)** Enhanced full support for `GPXExtensions` for both parsing and creating. 

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

## How to parse?
Parsing of GPX files is done by initializing `GPXParser`.

There are five ways of initializing `GPXParser`,  and these are three main ways of initializing:
#### You can initialize with a `URL`:
```Swift
guard let gpx = GPXParser(withURL: inputURL)?.parsedData() else { return }
```
#### With path:
```Swift
guard let gpx = GPXParser(withPath: inputPath)?.parsedData() else { return } // String type
```
#### With `Data`:
```Swift
let gpx = GPXParser(withData: inputData).parsedData()
```

`.parsedData()` returns a `GPXRoot` type, which contains all the metadata, waypoints, tracks, routes, and extensions(if any), which you can expect from a GPX file, depending on what that file contains.

### Making use of parsed GPX data
```Swift
guard let gpx = GPXParser(withURL: inputURL)?.parsedData() else { return // do things here when failed }
        
// waypoints, tracks, tracksegements, trackpoints are all stored as Array depends on the amount stored in the GPX file.
for waypoint in gpx.waypoints {  // for loop example, every waypoint is written
    print(waypoint.latitude)     // prints every waypoint's latitude, etc: 1.3521, as a Double object
    print(waypoint.longitude)    // prints every waypoint's latitude, etc: 103.8198, as a Double object
    print(waypoint.time)         // prints every waypoint's date, as a Date object
    print(waypoint.name)         // prints every waypoint's name, as a String
}
    print(gpx.metadata?.desc)    // prints description given in GPX file metadata tag
    print(gpx.metadata?.name)    // prints name given in GPX file metadata tag
                
```

## How to create?

You will first start off with a `GPXRoot`.

#### Initializing `GPXRoot`
```Swift
let root = GPXRoot(creator: "Your app name here!") // insert your app name here
```
Now, you can start adding things to your `GPXRoot`. This includes your metadata, waypoints, tracks, routes, as well as extensions(if any).

#### Adding waypoints to `GPXRoot`
```Swift
root.add(waypoints: arrayOfWaypoints) // adds an array of waypoints
root.add(waypoint: singleWaypoint)    // adds a single waypoint
```
#### Adding tracks to `GPXRoot`
```Swift
root.add(tracks: arrayOfTracks)       // adds an array of tracks
root.add(track: singleTrack)          // adds a single track
```

#### Adding routes to `GPXRoot`
```Swift
root.add(routes: arrayOfRoutes)       // adds an array of routes
root.add(route: singleRoute)          // adds a single route
```

#### Adding metadata to `GPXRoot`
```Swift
let metadata = GPXMetadata()
metadata.name = "Your Name Here"
metadata.desc = "Description of your GPX file"
root.metadata = metadata              // adds metadata stuff
```

### Example of application of `GPXRoot`
```Swift
let root = GPXRoot(creator: "Your app name here!")
var trackpoints = [GPXTrackPoint]()

let yourLatitudeHere: CLLocationDegrees = 1.3521
let yourLongitudeHere: CLLocationDegrees = 103.8198
let yourElevationValue: Double = 10.724

let trackpoint = GPXTrackPoint(latitude: yourLatitudeHere, longitude: yourLongitudeHere)
trackpoint.elevation = yourElevationValue
trackpoint.time = Date() // set time to current date
trackpoints.append(trackpoint)

let track = GPXTrack()                          // inits a track
let tracksegment = GPXTrackSegment()            // inits a tracksegment
tracksegment.add(trackpoints: trackpoints)      // adds an array of trackpoints to a track segment
track.add(trackSegment: tracksegment)           // adds a track segment to a track
root.add(track: track)                          // adds a track

print(root.gpx())				// prints the GPX formatted string

```
This would be what you get from `root.gpx()` in the above example: 
```XML
<?xml version="1.0" encoding="UTF-8"?>
<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" version="1.1" creator="Your app name here!">
	<trk>
		<trkseg>
			<trkpt lat="1.352100" lon="103.819800">
				<ele>10.724</ele>
				<time>2019-02-12T05:38:19Z</time>
			</trkpt>
		</trkseg>
	</trk>
</gpx>
```
- `.gpx()` of `GPXRoot` outputs a `String` which can then be packaged as a .GPX file.
- `.OutputToFile(saveAt:fileName:)` directly saves GPX contents to a URL specified.

## Dealing with Extensions
Extensions in GPX files are represented as `GPXExtensions` in CoreGPX. 
 
 ### Accessing GPX Files's extensions
 Once a GPX file is parsed, you can access the extensions, by using subscript, with the tag name.
 - Use `extensions["tagNameHere"]` to get a `GPXExtensionElement`, which will contain various data parsed.
 Alternatively, use `get(from parent: String?)` to get a dictionary of extension data parsed.
 
 ### Writing GPX extensions
 - Firstly, initialize GPXRoot using `init(withExtensionAttributes:, schemaLocation:)` to initialize with extension schema information on the main gpx header tag.
 - Secondly, initialize GPXExtensions whenever needed, to be added to the GPXRoot/or other elements, when needed.
 - Use function `append(at parent: String?, contents: [String : String])`  to write extension data. If no parent, use `nil`.
 
 To know more, please do read the documentation for `GPXExtensions` and `GPXExtensionsElement`.


## Example
To know in depth of what `CoreGPX` can bring, do check out the Example app.
To run the example project, simply clone the repo, and try it out straight away!

## Contributing
Contributions to this project will be more than welcomed. Feel free to add a pull request or open an issue.
If you require a feature that has yet to be available, do open an issue, describing why and what the feature could bring and how it would help you!

## License
CoreGPX is available under the MIT license. See the LICENSE file for more info. 
