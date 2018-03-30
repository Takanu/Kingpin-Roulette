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
	var kingpinRequestMsg = """
	The long lasting ruler of the criminal underworld is dead, and it demands a new *Kingpin*.
	"""
	
	/// The players that want to be the Kingpin.
	var suitors: [Player] = []
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Present the dliemna and ask for a player selection
	*/
	override func execute() {
		
		/////////////////
		// TUTORIAL
		
		// If the tutorial is on, try to build up the scenario a little
		if handle.useTutorial == true {
			
			let tutorial1 = """
			As members of the Kingpin's elite circle, you dominate the criminal underworld of the city and reap the rewards.

			Your unwavering loyalty and success has put you at an elevated status almost on par with the Kingpin, so long as you continue to be valuable.
			"""
			
			let tutorial2 = """
			Unfortunately, the Kingpin is unaware of two things.
			"""
			
			let tutorial3 = """
			First, that not everyone here is loyal and that plots to steal from the Kingpin's immense fortunes or bring them to justice are afoot.
			"""
			
			let tutorial4 = """
			Secondly, that the Kingpin themself would meet an untimely due to forces outside his elite circle.
			"""
			
			kingpinRequestMsg = """
			To restore order to the organisation, one of you will need to take the Kingpin's place.
			"""
			
			queue.message(delay: 2.sec,
										viewTime: 9.sec,
										message: tutorial1,
										chatID: tag.id)
			
			queue.message(delay: 2.sec,
										viewTime: 5.sec,
										message: tutorial2,
										chatID: tag.id)
			
			queue.message(delay: 2.sec,
										viewTime: 7.sec,
										message: tutorial3,
										chatID: tag.id)
			
			queue.message(delay: 2.sec,
										viewTime: 6.sec,
										message: tutorial4,
										chatID: tag.id)
			
		}
		
		
		
		
		/////////////////
		// SETUP
		
		queue.action(delay: 2.sec, viewTime: 0.sec) {
		
			// Setup a route for receiving kingpin requests
			let kingpinRequest = RouteListen(name: "kingpin",
																			 pattern: self.kingpinRequestKey.data,
																			 type: .callbackQuery,
																			 action: self.receiveKingpinRequest)
			
			self.baseRoute[["event"]]?.addRoutes(kingpinRequest)
			
			// Make the inline key set
			let inline = MarkupInline(withButtons: self.kingpinRequestKey)
			
			// Ask who wants to be the kingpin
			self.storedMessages["kingpin_req"] = self.request.sync.sendMessage(self.kingpinRequestMsg,
																																				 markup: inline,
																																				 chatID: self.tag.id)
			
			// Delay an event to finish the request
			self.queue.action(delay: KingpinDefault.kingpinSelectTime,
												viewTime: 0.sec,
												action: self.chooseKingpin)
			
		}
		
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Receive a request from someone to become the kingpin.
	*/
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
				"You've got an IRON FIST, i'm sure you'll get that promotion.",
				"You should have always been Kingpin, you work so hard!",
			]
			
			request.async.answerCallbackQuery(queryID: String(update.id),
																				text: alerts.getRandom!,
																				showAlert: true)
			
			// Update the message.
			var newMessage = kingpinRequestMsg
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
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Finish the candidacy process and select a new Kingpin.
	*/
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
		var firstMessageDelay = 4.sec
		
		
		// ONE PERSON NOMINATION
		
		if suitors.count == 1 {
		
			// Pick a Kingpin and let the players know.
			handle.kingpin = suitors.popRandom()!
			handle.kingpin!.role = KingpinRoles.kingpin
			let index = handle.players.index(where: {$0.id == handle.kingpin!.id})!
			handle.players.remove(at: index)
		
			announcement1 = """
			Through a series of unfortunate events, only one candidate remains as the new king of the criminal underworld...
			"""
		
			announcement2 = """
			...\(handle.kingpin!.name)! 🎉
			"""
		
		}
		
		// MULTIPLE NOMINATIONS
			
		else if suitors.count > 1 {
			
			handle.kingpin = suitors.popRandom()!
			handle.kingpin!.role = KingpinRoles.kingpin
			let index = handle.players.index(where: {$0.id == handle.kingpin!.id})!
			handle.players.remove(at: index)
			
			
			firstMessageDelay = 6.sec
			
			announcement1 = """
			After an intense multi-step interview process by an independent consultation firm, the new Kingpin of the criminal underworld is...
			"""
			
			announcement2 = """
			...\(handle.kingpin!.name)! 🎉
			"""
			
		}
		
		// NO NOMINATIONS
			
		else {
			
			handle.kingpin = handle.players.popRandom()!
			handle.kingpin!.role = KingpinRoles.kingpin
			
			firstMessageDelay = 8.sec
			
			announcement1 = """
			With no-one to turn to and no candidates to replace them, everyone turns to the Kingpin's bloodline to find the long lost heir to the empire.
			
			After a difficult search it is revealed that
			"""
			
			announcement2 = """
			...\(handle.kingpin!.name) is the long lost heir! 🎉
			"""
			
		}
		
		queue.message(delay: 2.sec,
									viewTime: firstMessageDelay,
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
