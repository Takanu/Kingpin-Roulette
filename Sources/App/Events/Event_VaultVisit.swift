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
	
	var visitorsLeft: [Player] = []
	
	// Present the dliemna and ask for a player selection
	override func execute() {
		
		// Mix up the character order for everyone that isn't the Kingpin.
		var tempPlayerContainer = handle.players
		var newPlayerOrder: [Player] = []
		
		while tempPlayerContainer.count != 0 {
			newPlayerOrder.append(tempPlayerContainer.popRandom()!)
		}
		
		handle.players = newPlayerOrder
		
		// If the tutorial is on, build up the scenario so people know what to expect.
		if handle.useTutorial == true {
			
			
		}
		
		
		
		
	}
	
	func visitVault() {
		
		// If we've been called but no-one is left to visit the vault, exit.
		if visitorsLeft.count == 0 {
			concludeVisit()
		}
		
		// Go through each player in the list and let them look and choose.
		
		// If the kingpin is asked to have a look, change the framing of the visit.
		
	}
	
	func concludeVisit() {
		
	}
}
