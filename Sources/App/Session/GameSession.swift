//
//  KingpinSession.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class GameSession: ChatSession {
	
	// GAME STATE
	/// The players currently participating in the game.
	var players: [Player] = []
	
	/** The "game inventory", containing the currently available roles and valuables.
	Only the player currently at the vault can see what's inside it. */
	var vault = Vault()
	
	/// Stored messages, used to implicitly store and fetch messages for editing or deletion.
	var storedMessages: [String: Message] = [:]
	
	// SPECIALS
	/// If true the tutorial has been enabled.
	private(set) var useTutorial = false
	
	/// If true, test mode has been intiated which allows you to play as all the roles at once.
	private(set) var testMode: Bool = false
	
	
	/**
	Initialise routes and any other core game elements before the start of the game.
	*/
	override func postInit() {
		
		// ROUTES
		let eventPass = RoutePass(name: "event", updateTypes: [.message, .editedMessage, .callbackQuery, .chosenInlineResult, .inlineQuery])
		
		// Build the "base" router, used to filter out blank updates.
		let baseClosure = { (update: Update) -> Bool in
			
			if update.from == nil { return false }
			if update.content == "" { return false }
			
			return true
		}
		
		baseRoute = RouteManual(name: "base", handler: baseClosure, routes: eventPass)
		
		// ANTI-FLOOD
		
		// FILTER
		
		
	}
	
	/**
	Starts the game sequence.
	*/
	func startGame(_ update: Update) -> Bool {
		
		// Request players.
		let handle = GameHandle(session: self)
		let newGameEvent = EventContainer<GameHandle>(event: Event_NewGame.self)
		newGameEvent.start(handle: handle) {
			
			// See if the game state changes allow us to start the game.
			self.resolveHandle(handle)
			
			// If not, send a message, reset and quit out.
			if self.players.count <= KingpinDefault.minimumPlayers {
				self.reset()
				return
			}
			
			// If yes, start the scenario.
			self.queue.action(delay: 2.sec, viewTime: 0.sec) {
				self.startScenario()
			}
			
		}
		
		
		
		return true
		
	}
	
	/**
	Starts the scenario (after characters have been selected).
	*/
	func startScenario() {
		
		// Ask for a kingpin pick
		
		// Pass the vault around
		
		// INTERROGATE
		
	}
	
	/**
	Announces the game results, everyone's roles and resets the game state.
	*/
	func finishScenario() {
		
	}
	
	/**
	Resolves the handle, passing over any changes made to this session.
	*/
	func resolveHandle(_ handle: GameHandle) {
		
	}
	
	/**
	Resets all game states and removes all proxies from each session.
	*/
	func reset() {
		players.forEach {
			$0.session_closeProxy()
		}
		
		self.players = []
		self.vault = Vault()
		self.storedMessages.removeAll()
		self.useTutorial = false
		self.testMode = false
		
		
	}
}
