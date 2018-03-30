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
	
	/// The number of players that are out.  The key is their current status, so use proper english plz.
	var eliminatedPlayers: [Player: String] = [:]
	
	/// The players that have won the game (obviously wont contain anything until the end).
	var winningPlayers: [Player] = []
	
	/** The "game inventory", containing the currently available roles and valuables.
	Only the player currently at the vault can see what's inside it. */
	var vault: Vault
	
	/// The number of lives/chances the kingpin has.  If they have no lives left, choosing anyone who isnt the player will cause them to lose the game.
	var kingpinLives = 0
	
	
	// STORAGE
	/// Stored messages, used to implicitly store and fetch messages for editing or deletion.
	var storedMessages: [String: Message] = [:]
	
	/// Schedules events stored on a temporary basis for update purposes.
	var storedEvents: [String: ScheduleEvent] = [:]
	
	
	// ROUTES
	/// The player route, allowing another player to choose a player.
	var playerRoute: PlayerRoute
	
	
	// SPECIALS
	/// If true the tutorial has been enabled.
	var useTutorial = false
	
	/// If yes, test mode has been intiated which allows you to play as all the roles at once.
	var testMode: Bool
	
	
	// ERROR EXIT
	private(set) var circuitBreaker: (String) -> ()
	
	init(session: GameSession) {
		self.tag = session.tag
		self.request = session.requests
		self.queue = session.queue
		self.baseRoute = session.baseRoute
		self.records = []
		
		self.players = session.players
		self.kingpin = session.kingpin
		self.eliminatedPlayers = session.eliminatedPlayers
		self.winningPlayers	= session.winningPlayers
		self.vault = session.vault
		
		self.playerRoute = session.playerRoute
		
		self.useTutorial = session.useTutorial
		self.testMode = session.testMode
		
		self.circuitBreaker = session.circuitBreaker
	}
	
	
}
