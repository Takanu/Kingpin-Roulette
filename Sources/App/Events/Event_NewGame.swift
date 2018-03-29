//
//  Event_NewGame.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class Event_NewGame: KingpinEvent, EventRepresentible {
	
	var eventName: String = "New Game"
	
	var eventType: EventType = EventType(name: "Kingpin Event",
																			 symbol: "👑",
																			 pluralisedName: "Kingpin Event",
																			 description: "oh hey, it's an event.")
	
	
	let characterKey = PlayerCharacter.inlineKey
	let tutorialKeyOff = MarkupInlineKey(fromCallbackData: "tutorial", text: "Use Tutorial (Currently Off)")!
	let tutorialKeyOn = MarkupInlineKey(fromCallbackData: "tutorial", text: "Use Tutorial (Currently On)")!
	
	// Setup the player stuff.
	override func execute() {
		
		// Set message contents
		let inline = MarkupInline(withButtons: characterKey, tutorialKeyOff)
		
		let message = """
		You have \(Int(KingpinDefault.charSelectTime.rawValue)) seconds to join.
		You'll need at least two other friends in order to play.
		"""
		
		// Set routes
		let tutorialToggle = RouteListen(pattern: "tutorial", type: .callbackQuery, action: tutorialSwitch)
		baseRoute[["event"]]?.addRoutes(tutorialToggle)
		
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
	
	// Toggle the tutorial.
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
}
