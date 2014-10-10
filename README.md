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
Include DKAsyncImageView.swift in your project and call one of the following methods to load an image asychronously with various options:



There are no external dependencies other than the Cocoa framework.
