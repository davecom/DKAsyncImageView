//
//  DKAsyncImageView.swift
//  The MIT License (MIT)
//
//  Copyright (c) 2014-2017 David Kopec
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
open class DKAsyncImageView: NSImageView, URLSessionDelegate, URLSessionDownloadDelegate {
    
    enum DownloadTaskResponse {
        case success(_ image: Data)
        case failure(_ error: Error?)
    }
    
    fileprivate var networkSession: URLSession {
        return currentNetworkSession ??
            URLSession.init(configuration:URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
    }
    fileprivate var currentNetworkSession: URLSession?
    
    fileprivate var imageURLDownloadTask: URLSessionDownloadTask?
    fileprivate var imageDownloadData: Data?
    fileprivate var errorImage: NSImage?
    
    fileprivate var spinningWheel: NSProgressIndicator?
    fileprivate var trackingArea: NSTrackingArea?
    
    var isLoadingImage: Bool = false
    var userDidCancel: Bool = false
    var didFailLoadingImage: Bool = false
    
    var completionHandler: ((Data?, Error?) -> Void)?
    
    fileprivate var attemptCompletionHandler: (DownloadTaskResponse) -> Void? { return respondToDownloadAttempt(withResponse:) }
    fileprivate var downloadTaskAttemptLimit: Int = 0
    fileprivate var downloadTaskAttempts: Int = 0
    
    fileprivate var toolTipWhileLoading: String?
    fileprivate var toolTipWhenFinished: String?
    fileprivate var toolTipWhenFinishedWithError: String?
    
    deinit {
        cancelDownload()
    }
    
    /// Grab an image form a URL and asynchronously load it into the image view
    ///
    /// - parameter url: A String representing the URL of the image.
    /// - parameter placeHolderImage: an optional NSImage to temporarily display while the image is downloading
    /// - parameter errorImage: an optional NSImage that displays if the download fails.
    /// - parameter usesSpinningWheel: A Bool that determines whether or not a spinning wheel indicator displays during download
    /// - parameter completion: A block to be executed when the download task finishes. The block takes two optional parameters: Data and Error and has no return value.
    open func downloadImageFromURL(_ url: String, placeHolderImage:NSImage? = nil, errorImage:NSImage? = nil, usesSpinningWheel: Bool = false, allowedAttempts: Int = 0, completion: ((Data?, Error?) -> Void)? = nil) {
        cancelDownload()
        
        completionHandler = completion
        downloadTaskAttemptLimit = allowedAttempts
        isLoadingImage = true
        didFailLoadingImage = false
        userDidCancel = false
        
        image = placeHolderImage
        self.errorImage = errorImage
        imageDownloadData = NSMutableData() as Data
        
        guard let URL = URL(string: url) else {
            isLoadingImage = false
            NSLog("Error: malformed URL passed to downloadImageFromURL")
            return
        }
        
        imageURLDownloadTask = networkSession.downloadTask(with: URL)
        imageURLDownloadTask?.resume()
        
        if usesSpinningWheel {
            if self.frame.size.height >= 64 && self.frame.size.width >= 64 {
                spinningWheel = NSProgressIndicator()
                if let spinningWheel = spinningWheel {
                    addSubview(spinningWheel)
                    spinningWheel.style = NSProgressIndicator.Style.spinning
                    spinningWheel.isDisplayedWhenStopped = false
                    spinningWheel.frame = NSMakeRect(self.frame.size.width * 0.5 - 16, self.frame.size.height * 0.5 - 16, 32, 32)
                    spinningWheel.controlSize = NSControl.ControlSize.regular
                    spinningWheel.startAnimation(self)
                }
                
            } else if (self.frame.size.height < 64 && self.frame.size.height >= 16) && (self.frame.size.width < 64 && self.frame.size.width >= 16) {
                spinningWheel = NSProgressIndicator()
                if let spinningWheel = spinningWheel {
                    addSubview(spinningWheel)
                    spinningWheel.style = NSProgressIndicator.Style.spinning
                    spinningWheel.isDisplayedWhenStopped = false
                    spinningWheel.frame = NSMakeRect(self.frame.size.width * 0.5 - 8, self.frame.size.height * 0.5 - 8, 16, 16)
                    spinningWheel.controlSize = NSControl.ControlSize.small
                    spinningWheel.startAnimation(self)
                }
            }
        }
    }
    
    /// Cancel the download
    open func cancelDownload() {
        userDidCancel = true
        isLoadingImage = false
        didFailLoadingImage = false

        if let networkSession = currentNetworkSession {
            networkSession.invalidateAndCancel()
        }
        
        resetForNewTask()
        image = nil
    }
    
    private func resetForNewTask() {
        imageDownloadData = nil
        imageURLDownloadTask = nil
        errorImage = nil
        
        downloadTaskAttempts = 0
        
        spinningWheel?.stopAnimation(self)
        spinningWheel?.removeFromSuperview()
    }
    
    
    fileprivate func failureReset() {
        isLoadingImage = false
        didFailLoadingImage = true
        userDidCancel = false
        
        networkSession.finishTasksAndInvalidate()
        
        image = errorImage
        resetForNewTask()
    }
    
    // MARK: Intermediate completion handler
    
    func respondToDownloadAttempt(withResponse response: DownloadTaskResponse) {
        
        switch response {
            
        case .success(let image):
            Swift.print("Image download task successful with URL.")
            isLoadingImage = false
            networkSession.finishTasksAndInvalidate()
            resetForNewTask()
            completionHandler?(image, nil)
            return
            
        case .failure(let error):
            if downloadTaskAttempts >= downloadTaskAttemptLimit {
                Swift.print("Image download task exceeded retry attempts.")
                image = errorImage
                completionHandler?(nil, error)
                failureReset()
                return
            }
            
            downloadTaskAttempts += 1
            Swift.print("Image download task retrying attempt \(downloadTaskAttempts) / \(downloadTaskAttemptLimit).")
        }
        
        guard let url = imageURLDownloadTask?.originalRequest?.url else {
            NSLog("Error: malformed URL passed to downloadImageFromURL internal retry.")
            return
        }
        
        imageURLDownloadTask = networkSession.downloadTask(with: url)
        imageURLDownloadTask?.resume()
    }
    
    //MARK: NSURLSessionDownloadTask Delegate
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        imageDownloadData = try? Data.init(contentsOf: location)
    }
    
    //MARK: NSURLSessionTask Delegate
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard error == nil else {
            if (error as NSError?)?.code == NSURLErrorCancelled {
                return
            }
            Swift.print(error!.localizedDescription)
            attemptCompletionHandler(.failure(error))
            return
        }
        
        didFailLoadingImage = false
        userDidCancel = false
        
        guard let data = imageDownloadData else {
            Swift.print("Image data not downloaded correctly.")
            attemptCompletionHandler(.failure(error))
            return;
        }
        guard let img: NSImage = NSImage(data: data) else {
            Swift.print("Error forming image from data.")
            attemptCompletionHandler(.failure(error))
            return;
        }
        
        image = img
        
        attemptCompletionHandler(.success(data))
    }
    
    //MARK: Tooltips
    
    /// Set tooltips for loading, finished, and error states
    ///
    /// - parameter ttip1: The tool tip to show while loading
    /// - parameter whenFinished: The tool tip that shows after the image downloaded.
    /// - parameter andWhenFinishedwithError: The tool tip that shows when an error occurs.
    open func setToolTipWhileLoading(_ ttip1: String?, whenFinished ttip2:String?, andWhenFinishedWithError ttip3: String?) {
        toolTipWhileLoading = ttip1
        toolTipWhenFinished = ttip2
        toolTipWhenFinishedWithError = ttip3
    }
    
    /// Remove all tooltips
    open func deleteToolTips() {
        toolTip = nil
        toolTipWhileLoading = nil
        toolTipWhenFinished = nil
        toolTipWhenFinishedWithError = nil
    }
    
    override open func mouseEntered(with theEvent: NSEvent) {
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
    
    override open func updateTrackingAreas() {
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        let opts: NSTrackingArea.Options = NSTrackingArea.Options(rawValue: NSTrackingArea.Options.mouseEnteredAndExited.rawValue | NSTrackingArea.Options.activeAlways.rawValue)
        trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self, userInfo: nil)
        if let trackingArea = trackingArea {
            self.addTrackingArea(trackingArea)
        }
        
    }
}
