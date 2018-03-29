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
	
	
	let characterKey = PlayerCharacter.inlineKey
	let tutorialKeyOff = MarkupInlineKey(fromCallbackData: "tutorial", text: "Use Tutorial (Currently Off)")!
	let tutorialKeyOn = MarkupInlineKey(fromCallbackData: "tutorial", text: "Use Tutorial (Currently On)")!
	
	/// The characters that have already been chosen by other players.
	var usedCharacters: [PlayerCharacter] = []
	
	/**
	Send the initial message and set timers.
	*/
	override func execute() {
		
		// Set message contents
		let inline = MarkupInline(withButtons: characterKey, tutorialKeyOff)
		
		let message = """
		You have \(Int(KingpinDefault.charSelectTime.rawValue)) seconds to join.
		You'll need at least two other friends in order to play.
		"""
		
		// Set routes
		let tutorialToggle = RouteListen(pattern: "tutorial", type: .callbackQuery, action: tutorialSwitch)
		let characterSelect = RoutePass(updateTypes: [.message], action: receiveCharacterSelection)
		
		baseRoute[["event"]]?.addRoutes(tutorialToggle, characterSelect)
		
		
		// Send the message!
		let startMsg = request.sync.sendMessage(message, markup: inline, chatID: tag.id)
		storedMessages["start_msg"] = startMsg
		storedMessages["current_msg"] = startMsg
		
		
		// Delay the warning message if we can
		let warningDelay = Int(KingpinDefault.charSelectTime.unixTime - 25)
		
		_ = queue.action(delay: warningDelay.sec, viewTime: 0.sec) {
			
			// Build the message
			var message = "You have 25 seconds left to join.\n\nPlayer List:\n"
			for player in self.handle.players {
				message += player.name + "\n"
			}
			
			// Remove the inline prompt on the old message
			let msg = self.storedMessages["current_msg"]!
			self.request.sync.editCaption(messageID: msg.tgID,
																		caption: msg.caption ?? "",
																		markup: nil,
																		chatID: self.tag.id)
			
			// Send the new message
			self.storedMessages["current_msg"] = self.request.sync.sendMessage(message, markup: inline, chatID: self.tag.id)
		}
	}
	
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
	
	/**
	Updates the latest join prompt with all current characters.
	*/
	func updateJoinMessage() {
		
		// Setup the properties needed to make the update.
		guard let currentMsg = storedMessages["current_msg"] else {
			print("\(#line) \(#function) - Current message disappeared when toggling the tutorial!")
			return
		}
		
		// Setup the new message
		var newMessage = currentMsg.text!
		newMessage += "\n\nPlayer List:"
		
		handle.players.forEach {
			newMessage += "\n\($0.name)"
		}
		
		// If we've reached the maximum number of players early, change the configuration.
		var reachedPlayerLimit = false
		if handle.players.count >= KingpinDefault.maximumPlayers {
			reachedPlayerLimit = true
		}
		
		// Setup the inline keys
		var newInline: MarkupInline?
		
		if reachedPlayerLimit == false {
			let tempInline = MarkupInline()
			
			if handle.useTutorial == true {
				tempInline.addRow(sequence: characterKey)
				tempInline.addRow(sequence: tutorialKeyOff)
				
			} else {
				tempInline.addRow(sequence: characterKey)
				tempInline.addRow(sequence: tutorialKeyOn)
			}
			
			newInline = tempInline
		}
		
		// Edit the message
		self.request.sync.editMessage(currentMsg.text ?? "Errr",
																	messageID: currentMsg.tgID,
																	inlineMessageID: nil,
																	markup: newInline,
																	chatID: tag.id)
		
		
			
		if reachedPlayerLimit == true {
			endCharacterSelection()
		}
		
	}
	
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
		
		let newInline = MarkupInline()
		var answerText = ""
		
		if handle.useTutorial == true {
			newInline.addRow(sequence: characterKey)
			newInline.addRow(sequence: tutorialKeyOff)
			handle.useTutorial = false
			answerText = "You've turned the tutorial off."
			
		} else {
			newInline.addRow(sequence: characterKey)
			newInline.addRow(sequence: tutorialKeyOn)
			handle.useTutorial = true
			answerText = "You've turned the tutorial on."
		}
		
		self.request.async.answerCallbackQuery(queryID: String(update.id),
																					 text: answerText,
																					 showAlert: true)
		
		self.request.sync.editMessage(currentMsg.text ?? "Errr",
																	messageID: currentMsg.tgID,
																	inlineMessageID: nil,
																	markup: newInline,
																	chatID: tag.id)
		
		return true
		
	}
	
	
	/**
	Ends the character selection phase.
	*/
	func endCharacterSelection() {
		storedMessages.removeAll()
		self.end(playerTrigger: nil, participants: nil)
	}
}
