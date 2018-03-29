//
//  Event_Interrogate.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class Event_Interrogate: KingpinEvent, EventRepresentible {
	
	var eventName: String = "Interrogate"
	
	var eventType: EventType = EventType(name: "Kingpin Event",
																			 symbol: "👑",
																			 pluralisedName: "Kingpin Event",
																			 description: "oh hey, it's an event.")
	
	// Present the dliemna and ask for a player selection
	override func execute() {
		
		// Pass vault control entirely to the Kingpin
		let interrogate1 = """
		Everyone has finished their first watch, and the Kingpin returns to see that the Vault is not as they left it.
		"""
		
		let interrogate2 = """
		
		"""
		
		queue.message(delay: 1.sec,
									viewTime: 5.sec,
									message: interrogate1,
									chatID: tag.id)
		
		// Give the kingpin the ability to accuse a player
		
		// Send a message to announce the state and WAIT...
		
	}
	
	func receivePlayerSelection() {
		
	}

}
