//
//  Event_NewGame.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

/**
Allows people to join the game, setting up join message prompts and building Player proxies for the main game.
*/
class Event_NewGame: KingpinEvent, EventRepresentible {
	
	var eventName: String = "New Game"
	
	var eventType: EventType = EventType(name: "Kingpin Event",
																			 symbol: "👑",
																			 pluralisedName: "Kingpin Event",
																			 description: "oh hey, it's an event.")
	
	
	/// Returns a complete inline key set for a join message, including context-sensitive tutorial buttons.
	var inlineMarkup: MarkupInline {
		
		let inline = MarkupInline()
		inline.addRow(sequence: PlayerCharacter.inlineKey)
		
		if handle.useTutorial == false {
			inline.addRow(sequence: MarkupInlineKey(fromCallbackData: "tutorial", text: "Use Tutorial (Currently Off)")!)
		} else {
			inline.addRow(sequence: MarkupInlineKey(fromCallbackData: "tutorial", text: "Use Tutorial (Currently On)")!)
		}
		
		return inline
	}
	
	/// The characters that have already been chosen by other players.
	var usedCharacters: [PlayerCharacter] = []
	
	var lastBaseMessage = ""
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Send the initial message and set timers.
	*/
	override func execute() {
		
		////////////
		// MESSAGE
		
		let message = """
		Secretly enter the criminal underworld as a friend, foe or the powerful Kingpin and settle your differences through a deadly interrogation game.
		
		You have \(Int(KingpinDefault.charSelectTime.rawValue)) seconds to join.
		This game is for 6-12 players.
		"""
		
		lastBaseMessage = message
		
		
		////////////
		// ROUTING
		
		let extendRoute = RouteCommand(commands: "extend", action: extendCharacterSelection)
		let tutorialToggle = RouteListen(pattern: "tutorial", type: .callbackQuery, action: tutorialSwitch)
		let characterSelect = RoutePass(updateTypes: [.message], action: receiveCharacterSelection)
		
		baseRoute[["event"]]?.addRoutes(extendRoute, tutorialToggle, characterSelect)
		
		
		// Send the message!
		let startMsg = request.sync.sendMessage(message,
																						markup: inlineMarkup,
																						chatID: tag.id)
		
		storedMessages["start_msg"] = startMsg
		storedMessages["current_msg"] = startMsg
		
		
		
		////////////
		// SCHEDULE
		
		
		// Insert a warning message if possible
		let warningDelay = Int(KingpinDefault.charSelectTime.unixTime - 25)
		
		if warningDelay > 40 {
			storedEvents["last_warning"] = queue.action(delay: warningDelay.sec, viewTime: 0.sec) {
				
				// Build the message
				let message = """
				You have 25 seconds left to join.

				\(self.getPlayerList())
				"""
				
				// Clear the inline of the previous message.
				self.clearPreviousInlineKeys()
				
				// Send the new message
				self.storedMessages["current_msg"] = self.request.sync.sendMessage(message,
																																					 markup: self.inlineMarkup,
																																					 chatID: self.tag.id)
			}
			
			_ = queue.action(delay: KingpinDefault.charSelectWarningTime,
											 viewTime: 0.sec) {
												
				self.endCharacterSelection(clearInline: true)
			}
			
		}
		
		// If not possible, just delay the ending of this event.
		else {
			_ = queue.action(delay: KingpinDefault.charSelectTime,
											 viewTime: 0.sec) {
												
				self.endCharacterSelection(clearInline: true)
			}
		}
		
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Handles character selections and player initialisation.
	*/
	func receiveCharacterSelection(_ update: Update) -> Bool {
		
		// Validate update content
		let usableChar = PlayerCharacter.cases().map({$0.rawValue})
		if usableChar.first(where: {update.content == $0}) == nil { return false }
		
		// Assert the linked session as a Player type and see if they have any proxies (and that this isn't a test).
		let session = update.linkedSessions[0] as! PlayerSession
		
		// If the player has already chosen and we're not in a test, dont accept another choice.
		if handle.testMode == false {
			if session.proxy != nil { return false }
		}
		
		// If we have the character available, build a Player proxy for them.
		if usedCharacters.contains(where: {$0.rawValue == update.content}) == false {
			
			let proxy = Player(session: session,
												 userInfo: session.info,
												 character: PlayerCharacter(rawValue: update.content)!)
			
			proxy.status = .joined
			usedCharacters.append(proxy.char)
			handle.players.append(proxy)
			
			// Work out how to assign the proxy
			if handle.testMode == false {
				if session.proxy == nil {
					session.proxy = proxy
				} else {
					session.testProxies.append(proxy)
				}
			}
			
			else {
				session.proxy = proxy
			}
			
			// Update the join message.
			updateJoinMessage()
		}
		
		// If not, tell them their character choice has been taken.
		else {
			_ = request.async.sendMessage("That character's already been taken, please pick another one.",
																		markup: nil,
																		chatID: tag.id)
		}
		
		return true
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Builds and returns an elegant player list.
	*/
	func getPlayerList() -> String {
		
		// Setup the new message
		var playerList = "Player List:"
		
		handle.players.forEach {
			playerList += "\n\($0.name)"
		}
		
		// Let the player know how many players they need to or can add to the game.
		if handle.players.count < KingpinDefault.minimumPlayers {
			let playersNeeded = KingpinDefault.minimumPlayers - handle.players.count
			playerList += "\n\n**You need \(playersNeeded) more players**"
		}
			
		else if handle.players.count < KingpinDefault.maximumPlayers {
			let playersNeeded = KingpinDefault.maximumPlayers - handle.players.count
			playerList += "\n\n**\(playersNeeded) more players can join**"
		}
		
		return playerList
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Updates the latest join prompt with all current characters.
	*/
	func updateJoinMessage() {
		
		// Setup the properties needed to make the update.
		guard let currentMsg = storedMessages["current_msg"] else {
			print("\(#line) \(#function) - Current message disappeared when toggling the tutorial!")
			return
		}
		
		let newMessage = getPlayerList()
		
		// If we've reached the maximum number of players early, change the configuration.
		var reachedPlayerLimit = false
		if handle.players.count >= KingpinDefault.maximumPlayers {
			reachedPlayerLimit = true
		}
		
		// Setup the inline keys
		var newInline: MarkupInline?
		
		if reachedPlayerLimit == false {
			newInline = inlineMarkup
		}
		
		// Edit the message
		self.request.sync.editMessage(newMessage,
																	messageID: currentMsg.tgID,
																	inlineMessageID: nil,
																	markup: newInline,
																	chatID: tag.id)
		
		storedMessages["current_msg"]!.text = newMessage
		
		
			
		if reachedPlayerLimit == true {
			endCharacterSelection(clearInline: false)
		}
		
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Toggle the tutorial.
	*/
	func tutorialSwitch(_ update: Update) -> Bool {
		
		// Validate update contents
		if handle.players.contains(where: {$0.id == update.from!.tgID}) == false {
			request.async.answerCallbackQuery(queryID: String(update.id),
																				text: "You can't change the tutorial settings unless you've joined the game.",
																				showAlert: true)
			return true
		}
		
		// Setup the properties needed to make the update.
		guard let currentMsg = storedMessages["current_msg"] else {
			print("\(#line) \(#function) - Current message disappeared when toggling the tutorial!")
			return true
		}
		
		// Toggle the tutorial boolean and select the answerer text.
		var answerText = ""
		
		if handle.useTutorial == true {
			handle.useTutorial = false
			answerText = "You've turned the tutorial off."
		} else {
			handle.useTutorial = true
			answerText = "You've turned the tutorial on."
		}
		
		
		self.request.async.answerCallbackQuery(queryID: String(update.id),
																					 text: answerText,
																					 showAlert: true)
		
		self.request.sync.editMessage(currentMsg.text ?? "Errr",
																	messageID: currentMsg.tgID,
																	inlineMessageID: nil,
																	markup: inlineMarkup,
																	chatID: tag.id)
		
		return true
		
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Extends the character selection phase, up to a point.
	*/
	func extendCharacterSelection(_ update: Update) -> Bool {
		
		var newMessage = """
		~ ~ T I M E   E X T E N S I O N ~ ~
		You now have
		"""
		
		return true
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Ends the character selection phase.
	*/
	func endCharacterSelection(clearInline: Bool) {
		
		if clearInline == true {
			self.clearPreviousInlineKeys()
		}
		
		storedMessages.removeAll()
		self.end(playerTrigger: nil, participants: nil)
	}
	
	/**
	Clears the inline keys of the current message.
	*/
	func clearPreviousInlineKeys() {
		
		let currentMsg = storedMessages["current_msg"]!
		self.request.sync.editMessage(currentMsg.text ?? "Errr",
																	messageID: currentMsg.tgID,
																	inlineMessageID: nil,
																	markup: nil,
																	chatID: tag.id)
		
	}
}
