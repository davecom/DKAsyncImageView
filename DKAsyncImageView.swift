//
//  DKAsyncImageView.swift
//  The MIT License (MIT)
//
//  Copyright (c) 2014 David Kopec
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

class DKAsyncImageView: NSImageView, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    private var imageURLConnection: NSURLConnection?
    private var imageDownloadData: NSMutableData?
    private var errorImage: NSImage?
    
    private var spinningWheel: NSProgressIndicator?
    private var trackingArea: NSTrackingArea?
    
    private var isLoadingImage: Bool = false
    private var userDidCancel: Bool = false
    private var didFailLoadingImage: Bool = false
    
    private var toolTipWhileLoading: String = ""
    private var toolTipWhenFinished: String = ""
    private var toolTipWhenFinishedWithError: String = ""
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func downloadImageFromURL(url: String) {
        downloadImageFromURL(url, placeHolderImage: nil, errorImage: nil, usesSpinningWheel: false)
    }
    
    func downloadImageFromURL(url: String, placeHolderImage: NSImage?) {
        downloadImageFromURL(url, placeHolderImage: placeHolderImage, errorImage: nil, usesSpinningWheel: false)
    }
    
    func downloadImageFromURL(url: String, placeHolderImage: NSImage?, errorImage: NSImage?) {
        downloadImageFromURL(url, placeHolderImage: placeHolderImage, errorImage: errorImage, usesSpinningWheel: false)
    }
    
    func downloadImageFromURL(url: String, placeHolderImage:NSImage?, errorImage:NSImage?, usesSpinningWheel: Bool) {
        cancelDownload()
        
        isLoadingImage = true
        didFailLoadingImage = false
        userDidCancel = false
        
        image = placeHolderImage
        self.errorImage = errorImage
        imageDownloadData = NSMutableData()
        
        var URL = NSURL(string: url)
        
        if URL == nil {
            isLoadingImage = false
            NSLog("Error: malformed URL passed to downloadImageFromURL")
            return
        }
            
        var conn: NSURLConnection? = NSURLConnection(request: NSURLRequest(URL: URL!), delegate: self)
        imageURLConnection = conn
        
        if usesSpinningWheel {
            if self.frame.size.height >= 64 && self.frame.size.width >= 64 {
                spinningWheel = NSProgressIndicator()
                if let spinningWheel = spinningWheel {
                    addSubview(spinningWheel)
                    spinningWheel.displayedWhenStopped = false
                    spinningWheel.frame = NSMakeRect(self.frame.size.width * 0.5 - 16, self.frame.size.height * 0.5 - 16, 32, 32)
                    spinningWheel.controlSize = NSControlSize.RegularControlSize
                    spinningWheel.startAnimation(self)
                }
                
            } else if 
        }
    }
    
    func cancelDownload() {
        userDidCancel = true
        isLoadingImage = false
        didFailLoadingImage = false
        
        deleteToolTips()
        
        spinningWheel?.stopAnimation(self)
        spinningWheel?.removeFromSuperview()
        
        imageURLConnection?.cancel()
        imageURLConnection = nil
        imageDownloadData = nil
        errorImage = nil
        image = nil
    }
    
    func deleteToolTips() {
        toolTip = ""
        toolTipWhileLoading = ""
        toolTipWhenFinished = ""
        toolTipWhenFinishedWithError = ""
    }
}