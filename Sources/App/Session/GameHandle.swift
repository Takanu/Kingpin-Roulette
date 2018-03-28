//
//  KingpinHandle.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class GameHandle: Handle {
	
	// INHERITANCE
	var tag: SessionTag
	var request: SessionRequest
	var queue: ChatSessionQueue
	var baseRoute: Route
	var records: [EventRecord]
	
	// GAME STATE
	/// The players currently participating in the game.
	var players: [Player]
	
	/** The "game inventory", containing the currently available roles and valuables.
	Only those in possession of the box can see whats inside it. */
	var vault: Vault
	
	init(session: GameSession) {
		self.tag = session.tag
		self.request = session.requests
		self.queue = session.queue
		self.baseRoute = session.baseRoute
		self.records = []
		
		self.players = session.players
		self.vault = session.vault
		
		
	}
	
	
}
