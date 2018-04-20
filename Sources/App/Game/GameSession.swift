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
	
	
	/// The number of players actively playing.
	var playerCount: Int {
		var result = players.count
		if kingpin != nil { result += 1 }
		return result
	}
	
	/// The kingpin.
	var kingpin: Player?
	
	/** The "game inventory", containing the currently available roles and valuables.
	Only the player currently at the vault can see what's inside it. */
	var vault: Vault!
  
  /// The game mode selected.
  var gameMode: KingpinGameMode = .standard
	
	/// The number of lives/chances the kingpin has.  If they have no lives left, choosing anyone who isnt the player will cause them to lose the game.
	var kingpinLives = 0
	
	/// The number of opals in the vault from the start.
	var startOpals = 0
	
	
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
	
	
	required init?(bot: PelicanBot, tag: SessionTag) {
		
		super.init(bot: bot, tag: tag)
		
    self.vault = Vault() { error in
      self.resolveError(event: nil, errorCode: error)
    }

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
		
		
		// (this affects normal messages, don't use it)
		
		// FILTER
//		// Add a filter to restrict commands to one per time window.
//		let commandFilter = UpdateFilterCondition(type: .message, timeRange: 3.sec) { condition in
//
//			let commands = condition.records.filter( {
//				if $0.type != .message { return false }
//				if $0.content.count == 0 { return false }
//				if $0.content.first! == "/" { return true }
//				return false
//			})
//
//			if commands.count > 0 { return false }
//			return true
//		}
//
//		self.filter.addCondition(commandFilter)
		
		
		// ANTI-FLOOD
		// Add anti-flood measures
		flood.add(type: [.message], hits: 20, duration: 40.sec) {
			
			let floodMsg = """
			(Oi, please don't spam me with messages.)
			"""
			
			_ = self.requests.sync.sendMessage(floodMsg,
																				 markup: nil,
																				 chatID: self.tag.id)
		}
		
		flood.add(type: [.message], hits: 40, duration: 120.sec) {
			
			let floodMsg = """
			(I warned you.  *pulls plug*)
			"""
			
			_ = self.requests.sync.sendMessage(floodMsg,
																				 markup: nil,
																				 chatID: self.tag.id)
			self.mod.blacklist()
		}
		
		// TIMEOUT
		self.timeout.set(updateTypes: [.message, .callbackQuery], duration: 30.min) {
			self.close()
		}
		
	}
	
	/**
	Starts the game sequence.
	*/
	func startGame(_ update: Update) -> Bool {
		
		// Disable the start command for now
		baseRoute[["start_command"]]?.enabled = false
		
		// Request players.
		let handle = GameHandle(session: self)
		let newGameEvent = EventContainer<GameHandle>(Event_NewGame.self)
		newGameEvent.start(handle: handle) { error in
			
			// See if the game state changes allow us to start the game.
			self.resolveHandle(handle)
			
			// If not, send a message, reset and quit out.
			if self.playerCount < KingpinDefault.minimumPlayers {
				
				self.requests.sync.sendMessage("Not enough players, cancelling!",
																			 chatID: self.tag.id)
				
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
    
    // Ask for the game mode
    let handle = GameHandle(session: self)
    let gameMode = EventContainer<GameHandle>(Event_GameMode.self)
    gameMode.start(handle: handle) { error in
      
      self.resolveHandle(handle)
      self.resolveError(event: Event_PickKingpin.self, errorCode: error)
		
      
      // Ask for a kingpin pick
      let handle = GameHandle(session: self)
      let pickKingpin = EventContainer<GameHandle>(Event_PickKingpin.self)
      pickKingpin.start(handle: handle) { error in
        
        self.resolveHandle(handle)
        self.resolveError(event: Event_PickKingpin.self, errorCode: error)
        
        
        // Pass the vault around
        let vaultVisit = EventContainer<GameHandle>(Event_VaultVisit.self)
        vaultVisit.start(handle: handle) { error in
          
          self.resolveHandle(handle)
          self.resolveError(event: Event_VaultVisit.self, errorCode: error)
          
          
          // INTERROGATE
          let interrogate = EventContainer<GameHandle>(Event_Interrogate.self)
          interrogate.start(handle: handle) { error in
            
            self.resolveHandle(handle)
            self.resolveError(event: Event_Interrogate.self, errorCode: error)
            
            if error == nil {
              self.finishScenario()
            }
          }
        }
      }
    }
  }
	
	/**
	Announces the game results, everyone's roles and resets the game state.
	*/
	func finishScenario() {
		queue.clear()
		
		/////////////
		// FINAL STANDINGS
		
		// Build a final game list
		var finalGameList = ""
		
		// Index every player including the kingpin, based on what their "Player Status" flair is.
		// Those without a status should be placed in an "Other" category.
		var statusCollection: [String: [Player]] = [:]
		var allPlayers = players
		allPlayers.append(kingpin!)
		
		for player in allPlayers {
			
			// If it has a type, use that to add it to the status collection
			if let type = player.flair[KingpinFlair.statusCategory] {
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
		
		// Take out the winner status collection first, we want that to be on top.
		let winners = statusCollection.removeValue(forKey: KingpinFlair.winner.name) ?? []
		finalGameList += listEndgameStateCategory(name: KingpinFlair.winner.name, players: winners)
		
		
		// Process the rest
		for status in statusCollection {
			finalGameList += listEndgameStateCategory(name: status.key, players: status.value)
		}
		
		
		/////////////
		// CREDITS
		
		let creditsMsg = """
		*Kingpin Roulette*
		Version \(KingpinDefault.versionNumber)
		
		*Designed and developed by @takanu.*
		*Based on the game Mafia De Cuba, designed by Philippe des Pallières and Loïc Lamy.*
		
		*Updates* - @takanubox
		*Chat* - @KingpinRoulette
		"""
		
		
		queue.message(delay: 1.sec,
									viewTime: 9.sec,
									message: finalGameList,
									chatID: tag.id)
		
		queue.message(delay: 1.sec,
									viewTime: 5.sec,
									message: creditsMsg,
									chatID: tag.id)
		
		queue.action(delay: 2.sec, viewTime: 0.sec, action: reset)
		
	}
	
	
	/**
	A supporting function for the scenario end, that helps format categories for
	players based on their end-game status.
	*/
	func listEndgameStateCategory(name: String, players: [Player]) -> String {
		
		if playerCount == 0 { return "" }
		
		var result = """
		\(name.uppercased())
		===========
		
		"""
		
		for player in players {
			result += "\(player.name) - \(player.role!.name)"
			
			if player.role?.definition == .thief {
				let stolenOpals = player.points[KingpinDefault.opal]?.int ?? 0
				result += " (Stole \(stolenOpals))"
			}
			
			result += "\n"
		}
		
		result += "\n"
		return result
	}
	
  /**
  Resolves any errors received as part of an event.
  */
  func resolveError(event: KingpinEvent.Type?, errorCode: Error?) {
    
    if errorCode == nil { return }
    
    queue.clear()
    baseRoute.clearAll()
    
    // If we just have a game mode selection error, send no error message and just leave.
    
    if errorCode is KingpinError {
      let kpError = errorCode as! KingpinError
      
      if kpError == .noGameModeSelected {
        self.reset()
        return
      }
    }
    
    let message = """
    Well shit, Kingpin encountered an error!

    ============================
    Error Code = \(errorCode!)
    ============================
    Hassle @takanu about it to get it fixed 🙏
    
    The game will now be reset...
    """
    
    requests.sync.sendMessage(message, chatID: tag.id)
    self.reset()
  }
	
	
	/**
	Resolves the handle, passing over any changes made to this session.
	*/
	func resolveHandle(_ handle: GameHandle) {
		
		self.players = handle.players
		self.kingpin = handle.kingpin
		
		self.vault = handle.vault
    self.gameMode = handle.gameMode 
		self.storedMessages.removeAll()
		self.storedEvents.removeAll()
		
		self.useTutorial = handle.useTutorial
		self.testMode = handle.testMode
		
	}
	
	/**
	Resets all game states and removes all proxies from each session, then closes the session.
	*/
	func reset() {
		
		startRoute.enabled = true
		eventRoute.enabled = true
		playerRoute.enabled = false
		
		self.queue.clear()
		
		self.kingpin?.close()
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
		
		self.close()
	}
}
