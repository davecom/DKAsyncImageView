//
//  DKAsyncImageView.swift
//  The MIT License (MIT)
//
//  Copyright (c) 2014-2016 David Kopec
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Cocoa

/// A Swift subclass of NSImageView for loading remote images asynchronously.
public class DKAsyncImageView: NSImageView, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    private var imageURLDownloadTask: NSURLSessionDownloadTask?
    private var networkSession: NSURLSession?
    private var imageDownloadData: NSData?
    private var errorImage: NSImage?
    
    private var spinningWheel: NSProgressIndicator?
    private var trackingArea: NSTrackingArea?
    
    var isLoadingImage: Bool = false
    var userDidCancel: Bool = false
    var didFailLoadingImage: Bool = false
    
    private var toolTipWhileLoading: String?
    private var toolTipWhenFinished: String?
    private var toolTipWhenFinishedWithError: String?
    
    deinit {
        cancelDownload()
    }
    
    /// Grab an image form a URL and asynchronously load it into the image view
    ///
    /// - parameter url: A String representing the URL of the image.
    /// - parameter placeHolderImage: an optional NSImage to temporarily display while the image is downloading
    /// - parameter errorImage: an optional NSImage that displays if the download fails.
    /// - parameter usesSpinningWheel: A Bool that determines whether or not a spinning wheel indicator displays during download
    public func downloadImageFromURL(url: String, placeHolderImage:NSImage? = nil, errorImage:NSImage? = nil, usesSpinningWheel: Bool = false) {
        cancelDownload()
        
        isLoadingImage = true
        didFailLoadingImage = false
        userDidCancel = false
        
        image = placeHolderImage
        self.errorImage = errorImage
        imageDownloadData = NSMutableData()
        
        guard let URL = NSURL(string: url) else {
            isLoadingImage = false
            NSLog("Error: malformed URL passed to downloadImageFromURL")
            return
        }
        
        networkSession = NSURLSession.init(configuration:NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        imageURLDownloadTask = networkSession!.downloadTaskWithURL(URL)
        
        imageURLDownloadTask?.resume()
        if usesSpinningWheel {
            if self.frame.size.height >= 64 && self.frame.size.width >= 64 {
                spinningWheel = NSProgressIndicator()
                if let spinningWheel = spinningWheel {
                    addSubview(spinningWheel)
                    spinningWheel.style = NSProgressIndicatorStyle.SpinningStyle
                    spinningWheel.displayedWhenStopped = false
                    spinningWheel.frame = NSMakeRect(self.frame.size.width * 0.5 - 16, self.frame.size.height * 0.5 - 16, 32, 32)
                    spinningWheel.controlSize = NSControlSize.RegularControlSize
                    spinningWheel.startAnimation(self)
                }
                
            } else if (self.frame.size.height < 64 && self.frame.size.height >= 16) && (self.frame.size.width < 64 && self.frame.size.width >= 16) {
                spinningWheel = NSProgressIndicator()
                if let spinningWheel = spinningWheel {
                    addSubview(spinningWheel)
                    spinningWheel.style = NSProgressIndicatorStyle.SpinningStyle
                    spinningWheel.displayedWhenStopped = false
                    spinningWheel.frame = NSMakeRect(self.frame.size.width * 0.5 - 8, self.frame.size.height * 0.5 - 8, 16, 16)
                    spinningWheel.controlSize = NSControlSize.SmallControlSize
                    spinningWheel.startAnimation(self)
                }
            }
        }
    }
    
    /// Cancel the download
    public func cancelDownload() {
        userDidCancel = true
        isLoadingImage = false
        didFailLoadingImage = false
        
        spinningWheel?.stopAnimation(self)
        spinningWheel?.removeFromSuperview()
        networkSession?.invalidateAndCancel()
        imageURLDownloadTask = nil
        imageDownloadData = nil
        errorImage = nil
        image = nil
    }
    
    
    private func failureReset() {
        isLoadingImage = false
        didFailLoadingImage = true
        userDidCancel = false
        
        spinningWheel?.stopAnimation(self)
        spinningWheel?.removeFromSuperview()
        
        imageDownloadData = nil
        imageURLDownloadTask = nil
        
        image = errorImage
        errorImage = nil
    }
    
    //MARK: NSURLSessionDownloadTask Delegate
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        
        imageDownloadData = NSData.init(contentsOfURL: location)
    }
    
    //MARK: NSURLSessionTask Delegate
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        guard error == nil else {
            Swift.print(error?.localizedDescription)
            failureReset()
            return;
        }
            
            
        didFailLoadingImage = false
        userDidCancel = false
        guard let data = imageDownloadData else {
            Swift.print("Image data not downloaded correctly.")
            failureReset()
            return;
        }
        guard let img: NSImage = NSImage(data: data) else {
            Swift.print("Error forming image from data.")
            failureReset()
            return;
        }
        image = img
        isLoadingImage = false
        
        spinningWheel?.stopAnimation(self)
        spinningWheel?.removeFromSuperview()
        imageDownloadData = nil
        imageURLDownloadTask = nil
        errorImage = nil

    }
    
    //MARK: Tooltips
    
    /// Set tooltips for loading, finished, and error states
    ///
    /// - parameter ttip1: The tool tip to show while loading
    /// - parameter whenFinished: The tool tip that shows after the image downloaded.
    /// - parameter andWhenFinishedwithError: The tool tip that shows when an error occurs.
    public func setToolTipWhileLoading(ttip1: String?, whenFinished ttip2:String?, andWhenFinishedWithError ttip3: String?) {
        toolTipWhileLoading = ttip1
        toolTipWhenFinished = ttip2
        toolTipWhenFinishedWithError = ttip3
    }
    
    /// Remove all tooltips
    public func deleteToolTips() {
        toolTip = nil
        toolTipWhileLoading = nil
        toolTipWhenFinished = nil
        toolTipWhenFinishedWithError = nil
    }
    
    override public func mouseEntered(theEvent: NSEvent) {
        if !userDidCancel {  // the user didn't cancel the operation so show the tooltips
            if isLoadingImage {
                if let toolTipWhileLoading = toolTipWhileLoading {
                    toolTip = toolTipWhileLoading
                } else {
                    toolTip = nil
                }
            }
            else if didFailLoadingImage {  //connection failed
                if let toolTipWhenFinishedWithError = toolTipWhenFinishedWithError {
                    toolTip = toolTipWhenFinishedWithError
                } else {
                    toolTip = nil
                }
            }
            else if !isLoadingImage { // it's not loading image
                if let toolTipWhenFinished = toolTipWhenFinished {
                    toolTip = toolTipWhenFinished
                } else {
                    toolTip = nil
                }
            }
        }
    }
    
    override public func updateTrackingAreas() {
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        let opts: NSTrackingAreaOptions = NSTrackingAreaOptions(rawValue: NSTrackingAreaOptions.MouseEnteredAndExited.rawValue | NSTrackingAreaOptions.ActiveAlways.rawValue)
        trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self, userInfo: nil)
        if let trackingArea = trackingArea {
            self.addTrackingArea(trackingArea)
        }
        
    }
}