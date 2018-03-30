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
	
}
