DKAsyncImageView
================

DKAsyncImageView is a Swift subclass of NSImageView for loading remote images asynchronously and displaying them on OS X.

This class is a port of [PVAsyncImageView](https://github.com/pedrovieira7/PVAsyncImageView) by [@pedrovieira7](https://github.com/pedrovieira7) from Objective-C to Swift. The features are the same, and re-enumerated here.

Features
----------------
* Download images from the Web to DKAsyncImageView asynchronously with just 1 line of code
* Set a 'Placheholder Image' to be displayed until the image is downloaded
* Set an 'Error Image' to be displayed when an error occurs while downloading the image
* Set ToolTips for each state -> Loading Image / Image Loaded / Error Loading Image
* Display a Spinning Wheel on top of DKAsyncImageView while it's downloading the image
* No external dependencies beyond the Cocoa frameworks

Documentation
----------------
Include `DKAsyncImageView.swift` in your project or use the CocoaPod `DKAsyncImageView`. Set an IB NSImageView's class as DKAsyncImageView or create it programmatically. In the latter case, use the standard NSImageView init methods. 

> Note: DKAsyncImageView 1.0.3 support Swift 4. Version 1.0.2 supports Swift 3. Version 1.0.1 supports Swift 2. Version 1.0 supports Swift 1.2.

**Download an Image**
```
func downloadImageFromURL(url: String, placeHolderImage: NSImage? = nil, errorImage: NSImage? = nil, usesSpinningWheel: Bool = false) 
```
At minimum, you simply must provide the URL of the image you want to asynchronously download. However, you also have the option of providing a `placeHolderImage` that displays while the download is taking place, and an `errorImage` that displays if the download is unsuccessful.

`usesSpinningWheel` specifies whether a spinning NSProgressIndicator appears over the NSImageView while the image is being downloaded.

**Set Tool Tips**
```
func setToolTipWhileLoading(ttip1: String?, whenFinished ttip2:String?, andWhenFinishedWithError ttip3: String?)
```

**Cancel a Download**
```
cancelDownload()
```

There are no external dependencies other than the Cocoa framework.

Future Direction/Ideas
----------------
* Make property based instead of method based
