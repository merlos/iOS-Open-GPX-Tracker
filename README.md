Open GPX Tracker for iOS + WatchOS
===============================================

[![Available on the app store](https://merlos.github.io/iOS-Open-GPX-Tracker/images/download-app-store.svg)](https://itunes.apple.com/app/open-gpx-tracker/id984503772)

Open GPX Tracker is a GPS logger for iOS (iPhone, iPad, iPod) with offline map cache support. Track your location, add waypoints and send your logs by email as GPX files.

This app has no annoying time restrictions, no ads and no in-app-purchases. Create unlimited GPX traces :).

If you are goint to track without Internet... don't worry! Just browse the area where you'll be tracking and it will be cached.

Requires iOS 9.0 or above. Open GPX tracker is an open source app.

![GPS Tracker logs](https://merlos.github.io/iOS-Open-GPX-Tracker/images/open-gpx-tracker-4-screenshots.png)

You can use Open GPX tracker for:

 - Creating routes and waypoints for editing Open Street Map.
 - Publishing Open Street Map Traces.
 - Creating real GPX files for testing your iOS apps in Xcode.

## Main Features

 - Displays tracking route in a map
 - Supports Apple Map Kit, [Open Street Map](http://wiki.openstreetmap.org/wiki/Tile_usage_policy) and [Carto DB](http://www.cartodb.com) as map sources
 - Offline maps support (of browsed areas)
 - Pause / Resume tracking
 - Add waypoint to user location
 - Add waypoint to any place in the map with a long press
 - Edit waypoint name
 - Drag & Drop waypoint pin
 - Remove waypoint
 - Load on map a saved session and continue tracking
 - Displays current location and altitude
 - Displays tracked time
 - Displays user heading (device orientation) 
 - Displays location accuracy 
 - Displays tracked distance (total and current segment)
 - GPX files can be imported from any other app using the share option
 - Share GPX files with other apps
 - File sharing through iTunes
 - Settings
    - Offline cache On/Off
    - Clear cache
    - Select the map server.
  - Darkmode
  - i18n support: English, German, Chinese (simplified), Spanish

### Apple Watch Features (since 1.6.0)
- Create GPX Files on your Apple Watch
- Pause/Resume tracking
- Save into GPX File
- Add waypoint to user location
- Send file to your paired device iPhone/iPad
- Display GPS Signal strength
- View current location information (speed, latitude, longitude, altitude)

## Install

The app is [available on the App Store](https://itunes.apple.com/app/open-gpx-tracker/id984503772) since May 2015.

Another option to install the app is to download the source code and compile it by yourself using Xcode. If you want to run it on a device, you also need an Apple developer account.

## Translate Open GPX Tracker
Open GPX tracker supports language translations (since 1.7.0). [See list of supported languages and how to translate the app into your language](https://github.com/merlos/iOS-Open-GPX-Tracker/wiki/How-to-translate-Open-GPX-Tracker-into-my-language).

## Download Source code
This application is written in Swift. To download the code run this command in a console:

```
 git clone https://github.com/merlos/iOS-Open-GPX-Tracker.git
```

Then, to test it open the file `OpenGpxTracker.xcworkspace` with XCode.

Please note the [limitations of using Open Street Maps Tile Servers](http://wiki.openstreetmap.org/wiki/Tile_usage_policy)

### Add a tile server
Adding a tile server is easy, just edit the file `GPXTileServer.swift`, uncomment the lines with `AnotherMap` and modify the templateUrl to point to the new tile server.

You have a list of tile servers in [Open Street Map Wiki](http://wiki.openstreetmap.org/wiki/Tile_servers)

## Reference documentation

The application is being documented using [jazzy](https://github.com/realm/jazzy) and following [NSHipster tutorial on swift documentation](https://nshipster.com/swift-documentation/).

![Documentation Status](https://www.merlos.org/iOS-Open-GPX-Tracker/docs/badge.svg)

[Read Source code documentation](https://www.merlos.org/iOS-Open-GPX-Tracker/docs/index.html)

## Contribute
You can contribute by forking and submitting a pull request.

Please note that by submitting any pull request you are providing me (Juan M. Merlos) the rights to include and distribute those changes also on the binary app published on the App Store (which is released under Apple's Standard License Agreement)

## License
Open GPX Tracker app for iOS.  Copyright (C) 2014  Juan M. Merlos (@merlos)

This program is free software: you can redistribute it and/or modify
it under the terms of the **GNU General Public License** as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

----

Please note that this source code was released under the GPL license.  So any change on the code shall be made publicly available and distributed under the GPL license (this does not apply to the pods included in the project which have their own license).

----

This app uses:
- [CoreGPX Framework](https://github.com/vincentneo/CoreGPX), a SWIFT library for using GPX files. Created by [@vincentneo](http://github.com/vincentneo)


Entry on the [Open Street Maps Wiki](https://wiki.openstreetmap.org/wiki/OpenGpxTracker)
