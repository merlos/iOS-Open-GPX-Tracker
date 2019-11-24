# MapCache Swift

<p><div style="text-align:center"><img src="https://github.com/merlos/MapCache/raw/master/images/MapCache.png"></div>
</p>

[![CI Status](https://travis-ci.com/merlos/MapCache.svg?branch=master)](https://travis-ci.org/merlos/MapCache)
[![Version](https://img.shields.io/cocoapods/v/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)
[![License](https://img.shields.io/cocoapods/l/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)
[![Platform](https://img.shields.io/cocoapods/p/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)
[![Documentation](https://www.merlos.org/MapCache/badge.svg)](http://merlos.org/MapCache)

The missing part of [MapKit](https://developer.apple.com/documentation/mapkit): A simple way to cache [map tiles](https://en.wikipedia.org/wiki/Tiled_web_map) and support offline browsing of maps.

Current features: 
* Automatically save tiles in a disk cache as user browses the map.
* You can to set cache capacity. Once the cache is full it will use a LRU (Least Recently Used) algorithm.
* Get Current cache size
* Clear existing cache
* Download a full region of the map
 
What is coming:
 * Smart predownloading/caching: anticipate tiles that may be needed during network idle
 * Background cache updates downloads
 * Improve documentation

## Installation
MapCache is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod 'MapCache'
```

## How to use the MapCache?
In the view controller where you have the `MKMapView` import `MapCache`

```swift
import MapCache
```

Then within the ViewController add

```swift
// ViewController.swift
class ViewController: UIViewController {
  @IBOutlet weak var map: MKMapView!

  override func viewDidLoad() {
    super.viewDidLoad()

    ...

    map.delegate = self

    ...

    // First setup the your cache
    let config = MapCacheConfig(withTileUrlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")

    // initialize the cache with our config
    mapCache = MapCache(withConfig: config)

    // We tell the MKMapView to use our cache
    _ = map.useCache(mapCache!)

    ...
}
```

Finally, tell the map delegate to use `mapCacheRenderer`

```swift
//ViewController.swift

// Assuming that ViewController is the delegate of the map
// add this extension:
extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return mapView.mapCacheRenderer(forOverlay: overlay)
    }
}

```
After setting up map cache browsed areas of the map will be kept on disk. If user browses again that area it will use the local version.
Note that in current version `0.1.0` cache has not expiration date so if you need to get a new version of the map you must call `clear()` which will wipe out the whole cache.

```swift
mapCache.clear() {
  // do something after clear
  print("cache cleared!")
}
```

To get current cache size:

```swift
mapCache.calculateSize()
``` 

## MapCache configuration
Config map cache is pretty straight forward, typically you will need to set only `urlTemplate` and probably the `subdomains`. 

These are the options:

```swift
var config = MapCacheConfig()

// Set the URL template. 
// For Open Street Maps you can chose: https://wiki.openstreetmap.org/wiki/Tile_servers
// It defaults to OpenStreetMaps servers 
//
// Below we set cartoDB Base map server (https://github.com/CartoDB/cartodb/wiki/BaseMaps-available)
config.urlTemplate: "https://${s}.basemaps.cartocdn.com/base-light/${z}/${x}/${y}.png"


// In the urlTemplate ${s} stands for subdomains, which allows you to balance 
// the load among the
// different tile servers.
// Default value is ["a","b","c"].
config.subdomains = ["a", "b"] 


// Cache Name is basically is the subfolder name in which the tiles are store.
// Default value is "MapCache"
config.cacheName = "Carto" 


// Max zoom supported by the tile server
// Default value is 19
config.maximumZ = 21

// Minimum zoom can also be set.
// config.minimumZ = 0 



// Capacity of the cache in bytes. Once the cache is full it uses a LRU algorithm 
// (Least Recently Used), that is, it removes the tiles last used a lot of time ago. 
// Each time a tile is retrieved from the cache it is updated the value of last time used.
// Default value of the capacity is unlimited.
config.capacity = 200 * 1024 * 1024 // 20 Megabytes


```

If you need to use MapCache in different controllers, to avoid issues just be sure to use the same values in the config.


## You may also like

* **[Open GPX Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker)**. A free source iOS App to create [GPX](https://en.wikipedia.org/wiki/GPS_Exchange_Format) tracks
* **[Core GPX](https://github.com/vincentneo/CoreGPX)** A swift library for managing GPX files by [Vincent Neo](https://github.com/vincentneo)

## License - MIT

Copyright (c) 2019 Juan M. Merlos [@merlos](http://twitter.com/merlos)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
