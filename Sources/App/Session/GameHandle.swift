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
	
	/// The kingpin.
	var kingpin: Player?
	
	/** The "game inventory", containing the currently available roles and valuables.
	Only the player currently at the vault can see what's inside it. */
	var vault: Vault
	
	/// Stored messages, used to implicitly store and fetch messages for editing or deletion.
	var storedMessages: [String: Message]
	
	// SPECIALS
	/// If true the tutorial has been enabled.
	var useTutorial = false
	
	/// If yes, test mode has been intiated which allows you to play as all the roles at once.
	var testMode: Bool
	
	init(session: GameSession) {
		self.tag = session.tag
		self.request = session.requests
		self.queue = session.queue
		self.baseRoute = session.baseRoute
		self.records = []
		
		self.players = session.players
		self.kingpin = session.kingpin
		self.vault = session.vault
		self.storedMessages = session.storedMessages
		
		self.useTutorial = session.useTutorial
		self.testMode = session.testMode
	}
	
	
}
