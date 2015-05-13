//
//  AppDelegate.swift
//  DKAsyncImageViewSample
//
//  Created by David Kopec on 10/11/14.
//  MIT Licensed
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var imageView: DKAsyncImageView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        imageView.downloadImageFromURL("http://www.google.com/images/logo.gif")
    }

}

