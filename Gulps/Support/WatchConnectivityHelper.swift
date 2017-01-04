//
//  WatchConnectivityHelper.swift
//  Gulps
//
//  Created by Andrea Mazzini on 12/11/15.
//  Copyright © 2015 Fancy Pixel. All rights reserved.
//

import Foundation
import RealmSwift
import WatchConnectivity

/**
 `WatchConnectivityHelper` handles the connection with WatchOS2
 */
public struct WatchConnectivityHelper {
  fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil

  /**
   Establishes the connection between the app and WatchOS2
   - Parameter delegate: an object implementing `WCSessionDelegate`
   */
  public func setupWatchConnectivity(delegate: WCSessionDelegate) {
    guard WCSession.isSupported() else {
      return
    }

    session?.delegate = delegate
    session?.activate()
  }

  /**
   Updates data on WatchOS, and listens for changes
   - Returns: RLMNotificationToken that needs to be retained
   */
  public func setupWatchUpdates() -> NotificationToken {
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
    guard let session = session else { return }

    let watchData = Settings.watchData(current: EntryHandler.sharedHandler.currentEntry().quantity)
    session.activate()
    if session.isWatchAppInstalled {
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
  public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    print("Receiving Context: \(applicationContext)")
    guard let new = applicationContext[Constants.WatchContext.current.key()] as? Double else { return }

    DispatchQueue.main.async {
      let current = EntryHandler.sharedHandler.currentEntry().quantity
      print("current: \(current)")
      if new > current {
        EntryHandler.sharedHandler.addGulp(new - current)
      }
    }
  }
}
