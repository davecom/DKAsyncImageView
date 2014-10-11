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

Documentation
----------------
Include DKAsyncImageView.swift in your project. Set an IB NSImageView's class as DKAsyncImageView or create it programmatically. In the latter case, use the standard NSImageView init methods.

**Download an Image**
```
func downloadImageFromURL(url: String)
func downloadImageFromURL(url: String, placeHolderImage: NSImage?) {
func downloadImageFromURL(url: String, placeHolderImage: NSImage?, errorImage: NSImage?)
func downloadImageFromURL(url: String, placeHolderImage:NSImage?, errorImage:NSImage?, usesSpinningWheel: Bool) 
```
*usesSpinningWheel* specifies whether a spinning NSProgressIndicator appears over the NSImageView while the image is being downloaded.

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
