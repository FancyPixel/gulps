//
//  WatchConnectivityHelper.swift
//  Gulps
//
//  Created by Andrea Mazzini on 12/11/15.
//  Copyright © 2015 Fancy Pixel. All rights reserved.
//

import Foundation
import Realm
import WatchConnectivity

/**
 `WatchConnectivityHelper` handles the connection with WatchOS2
 */
public struct WatchConnectivityHelper {

  /**
   Establishes the connection between the app and WatchOS2
   - Parameter delegate: an object implementing `WCSessionDelegate`
   */
  public func setupWatchConnectivity(delegate delegate: WCSessionDelegate) {
    guard WCSession.isSupported() else {
      return
    }

    let session = WCSession.defaultSession()
    session.delegate = delegate
    session.activateSession()
  }

  /**
   Updates data on WatchOS, and listens for changes
   - Returns: RLMNotificationToken that needs to be retained
   */
  public func setupWatchUpdates() -> RLMNotificationToken {
    sendWatchData()
    return EntryHandler.sharedHandler.realm.addNotificationBlock { note, realm in
      // Once a change in Realm is triggered, refresh the watch data
      self.sendWatchData()
    }
  }

  /**
   Sends the current data to WatchOS
   */
  public func sendWatchData() {
    guard WCSession.isSupported() else {
      return
    }

    let watchData = Settings.watchData(current: EntryHandler.sharedHandler.currentEntry().quantity)
    let session = WCSession.defaultSession()
    session.activateSession()
    if session.watchAppInstalled {
      do {
        try session.updateApplicationContext(watchData)
      } catch {
        print("Unable to send application context: \(error)")
      }
    }
  }

  /**
   Reads the new applications context and updates Realm if needed.
   It's triggered when a new portion is added on the watch
   */
  public func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    print("Receiving Context: \(applicationContext)")
    guard let new = applicationContext[Constants.WatchContext.Current.key()] as? Double else {
      return
    }

    dispatch_async(dispatch_get_main_queue()) {
      let current = EntryHandler.sharedHandler.currentEntry().quantity
      print("current: \(current)")
      if new > current {
        EntryHandler.sharedHandler.addGulp(new - current)
      }
    }
  }
}
