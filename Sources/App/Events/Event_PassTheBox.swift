//
//  Event_PassTheBox.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class Event_VaultVisit: KingpinEvent, EventRepresentible {
	
	var eventName: String = "Vault Visit"
	
	var eventType: EventType = EventType(name: "Kingpin Event",
																			 symbol: "👑",
																			 pluralisedName: "Kingpin Event",
																			 description: "oh hey, it's an event.")
	
	// Present the dliemna and ask for a player selection
	override func execute() {
		
		// Ask the kingpin to have a look and confirm they have indeed taken a look.
		
		// Go through each player in the list and let them look and choose.
		
		// Return!
		
	}
	
}
