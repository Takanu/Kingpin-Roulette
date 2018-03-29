//
//  Event_PickKingpin.swift
//  App
//
//  Created by Ido Constantine on 29/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class Event_PickKingpin: KingpinEvent, EventRepresentible {
	
	var eventName: String = "Pick Kingpin"
	
	var eventType: EventType = EventType(name: "Kingpin Event",
																			 symbol: "👑",
																			 pluralisedName: "Kingpin Event",
																			 description: "oh hey, it's an event.")
	
	
	/// The key used to ask players if they want to be the kingpin
	let kingpinRequestKey = MarkupInlineKey(fromCallbackData: "kingpin_req", text: "Use Tutorial (Currently Off)")!
	
	/// The message text used for the request
	let message = """
	Before we begin, one person must take the role of *Kingpin*.  Who wants that "promotion"?
	"""
	
	/// The players that want to be the Kingpin.
	var suitors: [Player] = []
	
	// Present the dliemna and ask for a player selection
	override func execute() {
		
		// Setup a route for receiving kingpin requests
		let kingpinRequest = RouteListen(name: "kingpin", pattern: kingpinRequestKey.data, type: .callbackQuery, action: receiveKingpinRequest)
		baseRoute[["event"]]?.addRoutes(kingpinRequest)
		
		// Ask who wants to be the kingpin
		storedMessages["kingpin_req"] = request.sync.sendMessage(message, chatID: tag.id)
		
		// Delay an event to finish the request
		queue.action(delay: KingpinDefault.kingpinSelectTime, viewTime: 0.sec, action: chooseKingpin)
		
		
	}
	
	func receiveKingpinRequest(_ update: Update) -> Bool {
		
		// Validate contents
		if handle.players.contains(where: {$0.id == update.from!.tgID}) == false { return false }
		
		// See if they haven't requested to be the kingpin before.
		if suitors.contains(where: {$0.id == update.from!.tgID}) == false {
			
			// Add them to the list.
			let kingpinSubmission = handle.players.first(where: {$0.id == update.from!.tgID})!
			suitors.append(kingpinSubmission)
			
			// Send them a winky callback query.
			let alerts = [
				"I'll put in a few good words for ya.",
				"You've got charisma, i'm sure you'll get that promotion.",
				"You should have always been Kingpin, you work so hard!",
			]
			
			request.async.answerCallbackQuery(queryID: String(update.id),
																				text: alerts.getRandom!,
																				showAlert: true)
			
			// Update the message.
			var newMessage = message
			newMessage += "\n\nCandidates:"
			
			for suitor in suitors {
				newMessage += "\n\(suitor.name)"
			}
			
		}
		
		return true
	}
	
	func chooseKingpin() {
		
		// Close the route and remove the inline button
		baseRoute[["event"]]?.clearAll()
		queue.clear()
		
		let msg = storedMessages["kingpin_req"]!
		request.sync.editMessage(msg.text!,
														 messageID: msg.tgID,
														 inlineMessageID: nil,
														 markup: nil,
														 chatID: tag.id)
		
		// Pick a Kingpin and let the players know.
		handle.kingpin = suitors.popRandom()!
		let index = handle.players.index(where: {$0.id == handle.kingpin!.id})!
		handle.players.remove(at: index)
		
		let announcement1 = """
		After an intense multi-step interview process, the new Kingpin of the criminal underworld is...
		"""
		
		let announcement2 = """
		...\(handle.kingpin!.name)! 🎉
		"""
		
		queue.message(delay: 2.sec,
									viewTime: 4.sec,
									message: announcement1,
									chatID: tag.id)
		
		queue.message(delay: 3.sec,
									viewTime: 4.sec,
									message: announcement2,
									chatID: tag.id)
		
		
		// Exit!
		queue.action(delay: 3.sec, viewTime: 0.sec) {
			self.end(playerTrigger: nil, participants: nil)
		}
		
	}
	
	
}
