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
	
	/// The kingpin.
	var kingpin: Player?
	
	/** The "game inventory", containing the currently available roles and valuables.
	Only the player currently at the vault can see what's inside it. */
	var vault: Vault!
	
	/// The number of lives/chances the kingpin has.  If they have no lives left, choosing anyone who isnt the player will cause them to lose the game.
	var kingpinLives = 0
	
	
	// STORAGE
	/// Stored messages, used to implicitly store and fetch messages for editing or deletion.
	var storedMessages: [String: Message] = [:]
	
	/// Schedules events stored on a temporary basis for update purposes.
	var storedEvents: [String: ScheduleEvent] = [:]
	
	
	// ROUTES
	/// The player route, allowing another player to choose a player.
	var playerRoute = PlayerRoute(inlineKey: Player.inlineKey)
	
	var eventRoute: RoutePass!
	
	var startRoute: RoutePass!
	
	
	// SPECIALS
	/// If true the tutorial has been enabled.
	private(set) var useTutorial = false
	
	/// If true, test mode has been intiated which allows you to play as all the roles at once.
	private(set) var testMode: Bool = false
	
	
	required init(bot: PelicanBot, tag: SessionTag, update: Update) {
		
		super.init(bot: bot, tag: tag, update: update)
		
		self.vault = Vault(circuitBreaker: self.circuitBreaker)
		self.eventRoute = RoutePass(name: "event", updateTypes: [.message, .editedMessage, .callbackQuery, .chosenInlineResult, .inlineQuery])
		self.startRoute = RoutePass(name: "start_command", updateTypes: [.message, .callbackQuery, .inlineQuery], action: self.startGame)
	}
	
	
	/**
	Initialise routes and any other core game elements before the start of the game.
	*/
	override func postInit() {
		
		// ROUTES
		// Build the "base" router, used to filter out blank updates.
		let baseClosure = { (update: Update) -> Bool in
			
			if update.from == nil { return false }
			if update.content == "" { return false }
			
			return true
		}
		
		baseRoute = RouteManual(name: "base", handler: baseClosure, routes: playerRoute, eventRoute, startRoute, vault)
		playerRoute.enabled = false
		
		
		
		// ANTI-FLOOD
		
		
		
		// FILTER
		
		
	}
	
	/**
	Starts the game sequence.
	*/
	func startGame(_ update: Update) -> Bool {
		
		// Disable the start command for now
		baseRoute[["start_command"]]?.enabled = false
		
		// Request players.
		let handle = GameHandle(session: self)
		let newGameEvent = EventContainer<GameHandle>(event: Event_NewGame.self)
		newGameEvent.start(handle: handle) {
			
			// See if the game state changes allow us to start the game.
			self.resolveHandle(handle)
			
			// If not, send a message, reset and quit out.
			if self.players.count < KingpinDefault.minimumPlayers {
				
				self.requests.sync.sendMessage("Not enough players, cancelling!",
																			 chatID: self.tag.id)
				
				self.reset()
				return
			}
			
			// If yes, start the scenario.
			self.queue.action(delay: 2.sec, viewTime: 0.sec) {
				self.populateVault()
				self.startScenario()
			}
			
		}

		return true
		
	}
	
	/**
	Depending on the number of players and game options selected, this will populate the vault with items.
	*/
	func populateVault() {
		
		if players.count == 0 { return }
		
		var itemCollection: [ItemRepresentible] = []
		itemCollection.append(KingpinRoles.bountyHunter)
		itemCollection.append(KingpinRoles.henchman)
		itemCollection.append(KingpinRoles.police)
		itemCollection.append(KingpinRoles.spy)
		itemCollection.append(KingpinRoles.thief)
		itemCollection.append(KingpinRoles.assistant)
		
		vault.roles.addItems(itemCollection)
		vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(15))
		
	}
	
	/**
	Starts the scenario (after characters have been selected).
	*/
	func startScenario() {
		
		// Ask for a kingpin pick
		let handle = GameHandle(session: self)
		let pickKingpin = EventContainer<GameHandle>(event: Event_PickKingpin.self)
		pickKingpin.start(handle: handle) {
			
			self.resolveHandle(handle)
			
			// FIXME - Ensure the kingpin was chosen.
			if self.kingpin == nil {
				self.circuitBreaker(message: "GameSession - A kingpin wasn't selected during the Kingpin phase.")
			}
			
			
			// Pass the vault around
			let vaultVisit = EventContainer<GameHandle>(event: Event_VaultVisit.self)
			vaultVisit.start(handle: handle) {
				
				self.resolveHandle(handle)
				
				
				// FIXME - Ensure everyone has a role, or otherwise exit early.
				if self.players.contains(where: {$0.role == nil }) == true {
					self.circuitBreaker(message: "GameSession - Not everyone got a role to use")
				}
				
				
				// INTERROGATE
				let interrogate = EventContainer<GameHandle>(event: Event_Interrogate.self)
				interrogate.start(handle: handle, next: self.finishScenario)
				
			}
		}
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
		
		self.players = handle.players
		self.kingpin = handle.kingpin
		
		self.vault = handle.vault
		self.storedMessages.removeAll()
		
		self.useTutorial = handle.useTutorial
		self.testMode = handle.testMode
		
	}
	
	/**
	Resets all game states and removes all proxies from each session.
	*/
	func reset() {
		
		self.baseRoute.clearAll()
		self.queue.clear()
		
		players.forEach {
			$0.close()
		}
		
		self.players = []
		self.kingpin = nil
		
		self.vault.resetRequest()
		self.storedMessages.removeAll()
		self.storedEvents.removeAll()
		
		self.useTutorial = false
		self.testMode = false
		
		
	}
	
	
	/**
	CIRCUIT BREAKER - Ends the game immediately and reports a problem.
	*/
	func circuitBreaker(message: String) {
		
		baseRoute[["event"]]?.clearAll()
		queue.clear()
		
		let errorMessage = """
		`OH CRAP AN ERROR OCCURRED`
		`=========================`
		\(message)
		`=========================`
		
		`RESETTING GAME`
		"""
		
		queue.message(delay: 2.sec,
									viewTime: 5.sec,
									message: errorMessage,
									chatID: tag.id)
		
		reset()
		
	}
}
