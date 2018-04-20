//
//  KingpinEvent.swift
//  App
//
//  Created by Ido Constantine on 29/03/2018.
//

import Foundation
import TrashBoat
import Pelican

/**
idk.
*/
class KingpinEvent: Event<GameHandle> {
	
	/// Stored messages, used to implicitly store and fetch messages for editing or deletion.
	var storedMessages: [String: Message] = [:]
	
	/// Schedules events stored on a temporary basis for update purposes.
	var storedEvents: [String: ScheduleEvent] = [:]
  
  
  /**
  Resets the event to the Handle state that all types had at the beginning of the event execution
  Use this if something goes wrong but is recoverable.
   
  - note: Use the message to print or send useful information about the issue.  Overriding is recommended to
  implement custom state changes and cleanup operations.
  */
  override func reset(_ error: Error?) {
    self.queue.clear()
    handle.baseRoute[["event"]]?.clearAll()
    
    let message = """
    *Uh-oh, we found an error.

    ============================
    Error Code = \(error.debugDescription)
    ============================
    
    We're gonna try to recover the game, sit tight \\o/
    """
    
    print("\(tag.id) | \(self) | Reset requested.  \"\(error.debugDescription)\"")
    request.sync.sendMessage(message, chatID: tag.id)
    
    queue.message(delay: 3.sec,
                  viewTime: 0.sec,
                  message: message,
                  chatID: tag.id)
    
    queue.action(delay: 3.sec, viewTime: 0.sec) {
      self.start(handle: self.handle)
    }
  }
  
  /**
  Abrubtly exit from an event if something goes wrong and is unrecoverable.
   
  - note: Use the message to print or send useful information about the issue.  Overriding is recommended to
  implement custom state changes and cleanup operations.
  */
  override func abort(_ error: Error?) {
    print("\(tag.id) | \(self) | Abort requested: \"\(error.debugDescription)\"")
    
    self.queue.clear()
    handle.baseRoute[["event"]]?.clearAll()
    
    // Clear references to the event for memory deallocation purposes.
    handle = nil
    request = nil
    sessions = nil
    queue = nil
    baseRoute = nil
    
    self.exit(error)
  }
	
}
