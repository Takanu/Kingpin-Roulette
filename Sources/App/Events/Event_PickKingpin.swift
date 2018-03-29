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
	let kingpinRequestKey = MarkupInlineKey(fromCallbackData: "kingpin_req", text: "Nominate Yourself")!
	
	
	/// The message text used for the request
	let message = """
	The long lasting ruler of the criminal underworld is dead, and it demands a new *Kingpin*.

	Who wants that promotion?
	"""
	
	/// The players that want to be the Kingpin.
	var suitors: [Player] = []
	
	// Present the dliemna and ask for a player selection
	override func execute() {
		
		// If the tutorial is on, try to build up the scenario a little
		if handle.useTutorial == true {
			
			
		}
		
		
		
		// Setup a route for receiving kingpin requests
		let kingpinRequest = RouteListen(name: "kingpin", pattern: kingpinRequestKey.data, type: .callbackQuery, action: receiveKingpinRequest)
		baseRoute[["event"]]?.addRoutes(kingpinRequest)
		
		// Make the inline key set
		let inline = MarkupInline(withButtons: kingpinRequestKey)
		
		// Ask who wants to be the kingpin
		storedMessages["kingpin_req"] = request.sync.sendMessage(message,
																														 markup: inline,
																														 chatID: tag.id)
		
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
			
			let oldMsg = storedMessages["kingpin_req"]!
			let inline = MarkupInline(withButtons: kingpinRequestKey)
			
			request.sync.editMessage(newMessage,
															 messageID: oldMsg.tgID,
															 inlineMessageID: nil,
															 markup: inline,
															 chatID: tag.id)
			
			storedMessages["kingpin_req"]!.text = newMessage
			
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
		
		var announcement1 = ""
		var announcement2 = ""
		
		
		// If at least one person nominated themselves, do this
		if suitors.count == 1 {
		
			// Pick a Kingpin and let the players know.
			handle.kingpin = suitors.popRandom()!
			let index = handle.players.index(where: {$0.id == handle.kingpin!.id})!
			handle.players.remove(at: index)
		
			announcement1 = """
			Through a series of unfortunate events, only one candidate remained as the new king of the criminal underworld...
			"""
		
			announcement2 = """
			...\(handle.kingpin!.name)! 🎉
			"""
		
		}
		
			
		// If multiple people wanted the top job
		else if suitors.count > 1 {
			
			handle.kingpin = suitors.popRandom()!
			let index = handle.players.index(where: {$0.id == handle.kingpin!.id})!
			handle.players.remove(at: index)
			
			announcement1 = """
			After an intense multi-step interview process, the new Kingpin of the criminal underworld is...
			"""
			
			announcement2 = """
			...\(handle.kingpin!.name)! 🎉
			"""
			
		}
		
			
		// If no-one wanted the job, pick someone at random.
		else {
			
			handle.kingpin = handle.players.popRandom()!
			
			announcement1 = """
			With no-one to turn to and no candidates to replace them, the long lost heir to the throne was discovered to be...
			"""
			
			announcement2 = """
			...\(handle.kingpin!.name)! 🎉
			"""
			
		}
		
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
