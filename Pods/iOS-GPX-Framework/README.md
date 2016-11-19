[![Version](http://cocoapod-badges.herokuapp.com/v/iOS-GPX-Framework/badge.png)](http://cocoadocs.org/docsets/iOS-KML-Framework)
[![Platform](http://cocoapod-badges.herokuapp.com/p/iOS-GPX-Framework/badge.png)](http://cocoadocs.org/docsets/iOS-KML-Framework)
 
[![License](http://img.shields.io/:license-mit-blue.svg)](http://opensource.org/licenses/mit-license.php)
[![Build](https://travis-ci.org/Pierre-Loup/iOS-GPX-Framework.svg)](https://travis-ci.org/Pierre-Loup/iOS-GPX-Framework)

iOS GPX Framework
============================

This is a iOS framework for parsing/generating GPX files.
This Framework parses the GPX from a URL or Strings and create Objective-C Instances of GPX structure. 

Fork infos
---------------------------------
This fork is the "iOS-GPX-Framework" pod's source repo. It has been created to migrate from a static framework based dependency mamagement to Cocoapods.


Installation
---------------------------------

iOS-KML-Framework is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

```ruby
platform :ios, '6.0'
pod 'iOS-GPX-Framework', "~> 0.0"
```

 Source files of the podified version are [on this repository](https://github.com/Pierre-Loup/iOS-GPX-Framework)
 
Usage
---------------------------------

```objc
//Import the umbrella header

#import "GPX.h"


//To parsing the GPX file, simply call the parse method :

GPXRoot *root = [GPXParser parseGPXWithString:gpx];


//You can generate the GPX :

GPXRoot *root = [GPXRoot rootWithCreator:@"Sample Application"];
    
GPXWaypoint *waypoint = [root newWaypointWithLatitude:35.658609f longitude:139.745447f];
waypoint.name = @"Tokyo Tower";
waypoint.comment = @"The old TV tower in Tokyo.";
    
GPXTrack *track = [root newTrack];
track.name = @"My New Track";
    
[track newTrackpointWithLatitude:35.658609f longitude:139.745447f];
[track newTrackpointWithLatitude:35.758609f longitude:139.745447f];
[track newTrackpointWithLatitude:35.828609f longitude:139.745447f];
```

# Usage with Swift
 
In order to use this library with the new Swift programming language you need to use the [Objective-C Bridging header] (https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html). 

Basically, you have to create a .h file that imports *GPX.h*

```objc
// <YourProjectName>/Bridge.h
 
 #ifndef GpxTest_Bridge_h
 #define GpxTest_Bridge_h
 
   #import "GPX.h"
 
 #endif
```
Then in Build Settings of your project name search for the key **"Objective-C Bridging header"** and add that file ie: *YourProjectName/Bridge.h*
  
That's it.
 
 
## Requirements

- iOS 6.0 or later

## Author

Watanabe Toshinori, t@flcl.jp

Cocoapod version created by [@Pierre-Loup](https://github.com/Pierre-Loup/)

## License

iOS-KML-Framework is available under the MIT license. See the LICENSE file for more info.

it uses [TBXML](http://tbxml.co.uk/TBXML/TBXML_Free.html) Copyright (c) 2009 Tom Bradley
