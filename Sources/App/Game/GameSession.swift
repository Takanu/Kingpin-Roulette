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
	
	var startRoute: RouteCommand!
	
	
	// SPECIALS
	/// If true the tutorial has been enabled.
	private(set) var useTutorial = false
	
	/// If true, test mode has been intiated which allows you to play as all the roles at once.
	private(set) var testMode: Bool = false
	
	
	required init(bot: PelicanBot, tag: SessionTag, update: Update) {
		
		super.init(bot: bot, tag: tag, update: update)
		
		self.vault = Vault(circuitBreaker: self.circuitBreaker)
		self.eventRoute = RoutePass(name: "event", updateTypes: [.message, .editedMessage, .callbackQuery, .chosenInlineResult, .inlineQuery])
		self.startRoute = RouteCommand(name: "start_command", commands: "start", action: self.startGame)
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
		
		if players.count < 6 {
			var itemCollection: [ItemRepresentible] = []
			
			itemCollection.append(KingpinRoles.rogue)
			itemCollection.append(KingpinRoles.henchman)
			itemCollection.append(KingpinRoles.police)
			itemCollection.append(KingpinRoles.spy)
			itemCollection.append(KingpinRoles.thief)
			itemCollection.append(KingpinRoles.assistant)
			
			vault.roles.addItems(itemCollection)
			vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(10))
		}
		
		
		if players.count == 6 {
			var itemCollection: [ItemRepresentible] = []
			
			itemCollection += [KingpinRoles.henchman, KingpinRoles.henchman]
			itemCollection.append(KingpinRoles.assistant)
			
			vault.roles.addItems(itemCollection)
			vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(10))
		}
		
		
		if players.count == 7 {
			var itemCollection: [ItemRepresentible] = []
			
			itemCollection += [KingpinRoles.henchman, KingpinRoles.henchman]
			itemCollection.append(KingpinRoles.assistant)
			
			vault.roles.addItems(itemCollection)
			vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(10))
		}
		
		
		if players.count == 8 {
			var itemCollection: [ItemRepresentible] = []
			let randomArrestRole = [KingpinRoles.police, KingpinRoles.spy].getRandom!
			
			itemCollection += [KingpinRoles.henchman, KingpinRoles.henchman]
			itemCollection.append(randomArrestRole)
			itemCollection.append(KingpinRoles.assistant)
			
			
			vault.roles.addItems(itemCollection)
			vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(12))
		}
		
		
		if players.count == 9 {
			var itemCollection: [ItemRepresentible] = []
			let randomArrestRole = [KingpinRoles.police, KingpinRoles.spy].getRandom!
			
			itemCollection += [KingpinRoles.henchman, KingpinRoles.henchman, KingpinRoles.henchman]
			itemCollection.append(randomArrestRole)
			itemCollection.append(KingpinRoles.assistant)
			
			vault.roles.addItems(itemCollection)
			vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(12))
		}
		
		
		if players.count == 10 {
			var itemCollection: [ItemRepresentible] = []
			
			itemCollection += [KingpinRoles.henchman, KingpinRoles.henchman, KingpinRoles.henchman, KingpinRoles.henchman]
			itemCollection.append(KingpinRoles.police)
			itemCollection.append(KingpinRoles.spy)
			itemCollection.append(KingpinRoles.assistant)
			
			vault.roles.addItems(itemCollection)
			vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(15))
		}
		
		
		if players.count == 11 {
			var itemCollection: [ItemRepresentible] = []
			
			itemCollection += [KingpinRoles.henchman, KingpinRoles.henchman, KingpinRoles.henchman, KingpinRoles.henchman]
			itemCollection.append(KingpinRoles.police)
			itemCollection.append(KingpinRoles.spy)
			itemCollection += [KingpinRoles.assistant, KingpinRoles.assistant]
			
			vault.roles.addItems(itemCollection)
			vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(15))
		}
		
		
		if players.count == 12 {
			var itemCollection: [ItemRepresentible] = []
			
			itemCollection += [KingpinRoles.henchman, KingpinRoles.henchman, KingpinRoles.henchman, KingpinRoles.henchman, KingpinRoles.henchman]
			itemCollection.append(KingpinRoles.police)
			itemCollection.append(KingpinRoles.spy)
			itemCollection += [KingpinRoles.assistant, KingpinRoles.assistant]
			
			vault.roles.addItems(itemCollection)
			vault.valuables.addCurrency(KingpinDefault.opal, initialAmount: .int(15))
		}
		
		
		
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
				interrogate.start(handle: handle) {
					self.resolveHandle(handle)
					self.finishScenario()
				}
				
			}
		}
	}
	
	/**
	Announces the game results, everyone's roles and resets the game state.
	*/
	func finishScenario() {
		queue.clear()
		
		
		// Build a final game list
		var finalGameList = """
		WINNERS!
		===========
		"""
		
		// Index every player including the kingpin, based on what their "Player Status" flair is.
		// Those without a status should be placed in an "Other" category.
		var statusCollection: [String: [Player]] = [:]
		var allPlayers = players
		allPlayers.append(kingpin!)
		
		for player in allPlayers {
			
			// If it has a type, use that to add it to the status collection/
			if let type = player.flair[KingpinFlair.category] {
				let typeName = type[0]
				if statusCollection[typeName] != nil {
					statusCollection[typeName]!.append(player)
				}
					
				else {
					statusCollection[typeName] = [player]
				}
			}
			
				
			// If not, add it to the "Other" category.
			else {
				if statusCollection["The Others"] != nil {
					statusCollection["The Others"]!.append(player)
				}
					
				else {
					statusCollection["The Others"] = [player]
				}
			}
		}
		
		for status in statusCollection {
			finalGameList += """
			\(status.key.uppercased())
			===========
			
			"""
			
			for player in status.value {
				finalGameList += "\(player.name) - \(player.role!.name)\n"
			}
			
			finalGameList += "\n"
		}
		
		
		queue.message(delay: 1.sec,
									viewTime: 5.sec,
									message: finalGameList,
									chatID: tag.id)
		
		queue.action(delay: 2.sec, viewTime: 0.sec, action: reset)
		
	}
	
	
	/**
	Resolves the handle, passing over any changes made to this session.
	*/
	func resolveHandle(_ handle: GameHandle) {
		
		self.players = handle.players
		self.kingpin = handle.kingpin
		
		self.vault = handle.vault
		self.storedMessages.removeAll()
		self.storedEvents.removeAll()
		
		self.useTutorial = handle.useTutorial
		self.testMode = handle.testMode
		
	}
	
	/**
	Resets all game states and removes all proxies from each session.
	*/
	func reset() {
		
		startRoute.enabled = true
		eventRoute.enabled = true
		playerRoute.enabled = false
		
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
