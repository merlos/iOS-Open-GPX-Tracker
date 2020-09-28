# MapCache Swift

<p><div style="text-align:center"><img src="https://github.com/merlos/MapCache/raw/master/images/MapCache.png"></div>
</p>

[![CI Status](https://travis-ci.com/merlos/MapCache.svg?branch=master)](https://travis-ci.org/github/merlos/MapCache)
[![Version](https://img.shields.io/cocoapods/v/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)
[![License](https://img.shields.io/cocoapods/l/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)
[![Platform](https://img.shields.io/cocoapods/p/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)
[![Documentation](https://www.merlos.org/MapCache/badge.svg)](http://merlos.org/MapCache)
![Swift](https://github.com/merlos/MapCache/workflows/Swift/badge.svg)

The missing part of [MapKit](https://developer.apple.com/documentation/mapkit): A simple way to cache [map tiles](https://en.wikipedia.org/wiki/Tiled_web_map) and support offline browsing of maps.

Current features:
* Automatically save tiles in a disk cache as user browses the map.
* You can to set cache capacity. Once the cache is full it will use a LRU (Least Recently Used) algorithm.
* Get Current cache size
* Clear existing cache
* Download a full region of the map (experimental)

What is coming:
 * Improve documentation
 * Smart predownloading/caching: anticipate tiles that may be needed during network idle
 * Background cache updates downloads
 

## Installation
MapCache is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod 'MapCache'
```

## How to use MapCache?
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

    // First setup the config of our cache. 
    // The only thing we must provide is the url template of the tile server.
    // (All other config options are explained below in the section MapCache Configuration)
    let config = MapCacheConfig(withUrlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")

    // initialize the cache with our config
    let mapCache = MapCache(withConfig: config)

    // We tell the MKMapView to use the cache
    // So whenever it requires a tile, it will be requested to the 
    // cache 
    map.useCache(mapCache)

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

Note that in current version cache has not expiration date so if you need to get an updated version of the tiles you must call `clear()` which will wipe out the whole cache.

```swift
mapCache.clear() {
  // do something after clear
  print("cache cleared!")
}
```

To get current cache size:

```swift
mapCache.calculateDiskSize()
```

You can take a look at the [**Example/ folder**](https://github.com/merlos/MapCache/tree/master/Example/MapCache) to see a complete implementation.

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

// Continues to show map tiles even beyond maximumZ
// config.overZoomMaximumZ = true


// Capacity of the cache in bytes. Once the cache is full it uses a LRU algorithm
// (Least Recently Used), that is, it removes the tiles last used a lot of time ago.
// Each time a tile is retrieved from the cache it is updated the value of last time used.
// Default value of the capacity is unlimited.
config.capacity = 200 * 1024 * 1024 // 200 Megabytes


```

If you need to use MapCache in different controllers, to avoid issues just be sure to use the same values in the config.

## How does `MapCache` work behind the scenes

If you need to build on something top of MapCache read this. If not, you can ignore

MapCache is a hack of [MapKit](https://developer.apple.com/documentation/mapkit), the map framework of Apple.

### Understanding MapCache bootstrap

As explained in _How to use MapCache?_ section, in order to bootstrap MapCache we have to call this method

```swift
map.useCache(mapCache)
```

Where map is an instance of `MKMapView`, the main class used to display a map in iOS. What MapCache does through the extension (`MKMapView+MapCache`) is to add a new method `useCache` that tells `MKMapView` to display in the map a new tile layer on top of the default layers.  Because of this while the tiles are loaded you may see  the names of the default Apple Maps.

This extension also adds a variable in the `MKMapView` to keep the cache config.

A layer in the map is called _overlay_ in the MapKit terminology. MapCache uses [tile based overlay](https://en.wikipedia.org/wiki/Tiled_web_map).  implemented in the class `CachedTileOverlay` which is a subclass of [MKTileOverlay](https://developer.apple.com/documentation/mapkit/mktileoverlay). 

Overlays, have associated _renderers_ that are the actual classes that draw the content of an overlay in the screen. For example, there  are rendererers for points, lines, polygons, and tiles. When `MapView` needs to display an overlay it calls the delegate with the overlay it is going to render and you need to provide the renderer to use. In order to do that, We added a method `mapCacheRenderer` that just returns the default [MKTileOverlayRenderer](https://developer.apple.com/documentation/mapkit/mktileoverlay) when the class of the overlay passed as argument is of the type `CachedTileOverlay`.  That is why we need to add this code on the application in the delegate of the map view (`MKMapViewDelegate`) :

```swift
extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return mapView.mapCacheRenderer(forOverlay: overlay)
    }
}
```

### `CachedTileOverlay` and `MapCacheProtocol`

As mentioned earlier, `CachedTileOverlay` is tile based layer that is implemented as a subclass of [MKTileOverlay](https://developer.apple.com/documentation/mapkit/mktileoverlay). Basically, the only thing that it does is to override two methods of the parent class:

1.  `func url(forTilePath path: MKTileOverlayPath) -> URL`. The goal of this method is to return the URL of the tile. We need to overwrite it to be able to use the tile server of our preference.    

2. `func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void)`. This method is the one that returns the actual Tile.

If you take a look to the [implementation of `CachedTileOverlay`](https://github.com/merlos/MapCache/blob/master/MapCache/Classes/CachedTileOverlay.swift) you will notice that it only forwards the request a method with the same signature of a variable called `mapCache` which is an instance of a class that implements  `MapCacheProtocol` 

```
override public func url(forTilePath path: MKTileOverlayPath) -> URL {`
       return mapCache.url(forTilePath: path)
   }
```

The [`MapCacheProtocol definition`](https://github.com/merlos/MapCache/blob/master/MapCache/Classes/MapCacheProtocol.swift) is pretty simple, it just requires to have a config variable instance of a `MapCacheConfig` and an implementation of the two methods that are called from `CachedTileOverlay`

```
public protocol MapCacheProtocol {

    var config: MapCacheConfig { get set }

    func url(forTilePath path: MKTileOverlayPath) -> URL

    func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void)
```

If you need to create a custom implementation of the cache, you just need to create a class that implements this protocol and initialize the cache using  `map.useCache(myCustomCacheImplementationInstance)`. The implementation provided by the library is on the class named as  `MapCache`.

Something that may be useful too is the `DiskCache` class.

If you need further information you can take a look at 

### [Reference documentation of MapCache](http://www.merlos.org/MapCache/).


## You may also like

* **[Open GPX Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker)**. A free source iOS App to create [GPX](https://en.wikipedia.org/wiki/GPS_Exchange_Format) tracks
* **[Core GPX](https://github.com/vincentneo/CoreGPX)** A swift library for managing GPX files by [Vincent Neo](https://github.com/vincentneo)

## License - MIT

Copyright (c) 2019-2020 Juan M. Merlos [@merlos](http://twitter.com/merlos), and contributors.

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
