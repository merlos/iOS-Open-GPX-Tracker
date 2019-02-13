# CoreGPX
Parse, generate GPX files on iOS, watchOS & macOS.

[![CI Status](https://travis-ci.com/vincentneo/CoreGPX.svg?branch=master)](https://travis-ci.com/vincentneo/CoreGPX)
[![Swift Version](https://img.shields.io/badge/Swift-4.2-orange.svg)](https://swift.org/blog/swift-4-2-released/)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)
[![Platform](https://img.shields.io/cocoapods/p/CoreGPX.svg?style=flat)](https://cocoapods.org/pods/CoreGPX)
[![Version](https://img.shields.io/cocoapods/v/CoreGPX.svg?style=flat)](https://cocoapods.org/pods/CoreGPX)

# What is CoreGPX?
CoreGPX is a port of iOS-GPX-Framework to Swift language. It aims to be more than a port of the abandoned project, so do expect more features to be added in the future, as development is currently under progress.

It makes use of `XMLParser` for parsing GPX files, thus making it fully dependent on the native APIs only.

## Features
- [x] Successfully outputs string that can be packaged into a GPX file
- [x] Parses GPX files using native XMLParser
- [x] Support for macOS & watchOS

## How to parse?
Parsing of GPX files is done by initializing `GPXParser`.

There are three ways of initializing `GPXParser`:
### You can initialize with a `URL`:
```Swift
let gpx = GPXParser(withURL: inputURL).parsedData()
```
### With path:
```Swift
let gpx = GPXParser(withPath: inputPath).parsedData() // String type
```
### Or with `Data`:
```Swift
let gpx = GPXParser(withData: inputData).parsedData()
```

`.parsedData()` returns a `GPXRoot` type, which contains all the metadata, waypoints, tracks, routes, and extensions(if any), which you can expect from a GPX file, depending on what that file contains.

### Making use of parsed GPX data
```Swift
let gpx = GPXParser(withURL: inputURL).parsedData()
        
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

You will first start of with `GPXRoot`.

### Initializing `GPXRoot`
```Swift
let root = GPXRoot(creator: "Your app name here!") // insert your app name here
```
Now, you can start adding things to your `GPXRoot`. This includes your metadata, waypoints, tracks, routes, as well as extensions(if any).

### Adding waypoints to `GPXRoot`
```Swift
root.add(waypoints: arrayOfWaypoints) // adds an array of waypoints
root.add(waypoint: singleWaypoint)    // adds a single waypoint
```
### Adding tracks to `GPXRoot`
```Swift
root.add(tracks: arrayOfTracks)       // adds an array of tracks
root.add(track: singleTrack)          // adds a single track
```

### Adding routes to `GPXRoot`
```Swift
root.add(routes: arrayOfRoutes)       // adds an array of routes
root.add(route: singleRoute)          // adds a single route
```

### Adding metadata to `GPXRoot`
```Swift
let metadata = GPXMetadata()
metadata.name = "Your Name Here"
metadata.desc = "Description of your GPX file"
root.metadata = metadata              // adds metadata stuff
```

### Example of application of `GPXRoot`
```Swift
let root = GPXRoot(creator: "Your app name here!")
let trackpoints = [GPXTrackPoint]()

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
        
self.gpxString = root.gpx()
print(gpxString)
// gpxString contents
/* 
<?xml version="1.0" encoding="UTF-8"?>
<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" version="1.1" creator="example app">
	<trk>
		<trkseg>
			<trkpt lat="1.352100" lon="103.819800">
				<ele>10.724</ele>
				<time>2019-02-12T05:38:19Z</time>
			</trkpt>
		</trkseg>
	</trk>
</gpx>
*/
```
`.gpx()` of `GPXRoot` outputs a `String` which can then be packaged as a .GPX file.

## Example
To run the example project, clone the repo, and try out the Example!

## Contributing
Contributions to this project will be more than welcomed. Feel free to add a pull request or open an issue.

#### TO DO Checklist
Any help would be appreciated!
- [ ] Extension to metadata to support collection of more info in GPX file
- [ ] Add tests
- [ ] Documentation
- [ ] Code optimisation
- [ ] New features


## Installation

CoreGPX will be available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CoreGPX'
```

## License

CoreGPX is available under the MIT license. See the LICENSE file for more info.
