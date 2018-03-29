//
//  Event_PickKingpin.swift
//  App
//
//  Created by Ido Constantine on 29/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class Event_PickKingpin: KingpinEvent, EventRepresentible {
	
	var eventName: String = "Pick Kingpin"
	
	var eventType: EventType = EventType(name: "Kingpin Event",
																			 symbol: "👑",
																			 pluralisedName: "Kingpin Event",
																			 description: "oh hey, it's an event.")
	
	// Present the dliemna and ask for a player selection
	override func execute() {
		
		// Ask who wants to be the kingpin
		
		// Mix up the player order (apart from the Kingpin, who always goes first)
		
		// Exit and let the Vault Visit event deal with inline responses.
		
	}
	
}
