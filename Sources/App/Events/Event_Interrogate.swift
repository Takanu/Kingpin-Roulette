//
//  Event_Interrogate.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class Event_Interrogate: KingpinEvent, EventRepresentible {
	
	var eventName: String = "Interrogate"
	
	var eventType: EventType = EventType(name: "Kingpin Event",
																			 symbol: "👑",
																			 pluralisedName: "Kingpin Event",
																			 description: "oh hey, it's an event.")
	
	
	let revealMsg = """
	The Henchman stands up in front of the elites and makes a DECLARATION!
	"""
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Start the interrogation proceedings!
	*/
	override func execute() {
		
		///////////////////////////
		// TUTORIAL
		if handle.useTutorial {
			
		}
		
		// Pass vault control entirely to the Kingpin
		let interrogate1 = """
		Everyone has finished their first watch, and the Kingpin returns to see that the Vault is not as they left it.
		"""
		
		let interrogate2 = """
		Furious, the Kingpin gathers their Vault watchers in an attempt to work out who stole their precious Opals.

		Everyone gathers at the Kingpin's headquarters for the most serious meeting of their lives.
		"""
		
		///////////////////////////
		// SETUP
		// Give the kingpin the ability to accuse a player
		handle.playerRoute.newRequest(selectors: [handle.kingpin!],
																	targets: handle.players,
																	includeSelf: false,
																	includeNone: false,
																	next: receivePlayerSelection,
																	anonymiser: nil)
		
		handle.kingpin?.playerRoute.enabled = true
		
		
		// Send a message to announce the state and give the Kingpin generous time to choose...
		queue.message(delay: 1.sec,
									viewTime: 5.sec,
									message: interrogate1,
									chatID: tag.id)
		
		queue.message(delay: 1.sec,
									viewTime: 9.sec,
									message: interrogate2,
									chatID: tag.id)
		
		
		// Request a player selection.
		queue.action(delay: 3.sec, viewTime: 0.sec, action: requestPlayer)
		
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Ask the Kingpin to make a new selection.
	*/
	func requestPlayer() {
		
		// Set the messages
		let reminder1 = """
		(Kingpin, you have 5 minutes to choose who you think has stolen your Opals)

		(Choose wisely)
		"""
		
		let reminder2 = """
		(You have \(Int(KingpinDefault.kingpinInterrogationFirstWarning.rawValue)) seconds left to make a choice)
		"""
		
		let reminder3 = """
		(You have \(Int(KingpinDefault.kingpinInterrogationLastWarning.rawValue)) seconds left to make a choice)
		"""
		
		// Build the inline response.
		let inline = MarkupInline()
		inline.addRow(sequence: Vault.inlineKey)
		inline.addRow(sequence: Player.inlineKey)
		
		
		// Setup the timers
		let firstWarnTime = Int(KingpinDefault.kingpinInterrogationTime.rawValue - KingpinDefault.kingpinInterrogationFirstWarning.rawValue)
		let secondWarnTime = Int(KingpinDefault.kingpinInterrogationFirstWarning.rawValue - KingpinDefault.kingpinInterrogationLastWarning.rawValue)
		let finishTime = Int(KingpinDefault.kingpinInterrogationLastWarning.rawValue)
		
		self.queue.message(delay: 2.sec,
											 viewTime: 0.sec,
											 message: reminder1,
											 markup: inline,
											 chatID: self.tag.id)
		
		self.queue.message(delay: firstWarnTime.sec,
											 viewTime: 0.sec,
											 message: reminder2,
											 markup: inline,
											 chatID: self.tag.id)
		
		self.queue.message(delay: secondWarnTime.sec,
											 viewTime: 0.sec,
											 message: reminder3,
											 markup: inline,
											 chatID: self.tag.id)
		
		self.queue.action(delay: finishTime.sec,
											viewTime: 0.sec,
											action: self.finishEarly)
		
	}

	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Receive the Kingpin's selection and decide what to do with it.
	*/
	func receivePlayerSelection() {
		queue.clear()
		
		// Get the Kingpin's choice
		let result = handle.playerRoute.getResults()
		handle.playerRoute.resetRequest()
		
		if result.count == 0 {
			handle.circuitBreaker("Event_Interrogate - Expected to receive a player selection, but got nothing")
			return
		}
		
		if result[0].choice == nil {
			handle.circuitBreaker("Event_Interrogate - Vault route set, but no options available.")
			return
		}
		
		let kingpinChoice = result[0].choice! as! Player
		
		// Buffer padding for consistency
		queue.action(delay: 2.sec, viewTime: 0.sec, action: { })
		
		
		///////////////////////////
		// CONSEQUENCES
		// Based on their choice, decide what to do next
		
		// ACCUSE MSG
		let chosenMsg = """
		\(kingpinChoice.name) stands to the table.
		
		Their role becomes revealed...
		"""
		
		let roleMsg = """
		\(kingpinChoice.name) was the \(kingpinChoice.role!.name)!
		"""
		
		queue.message(delay: 3.sec,
									viewTime: 5.sec,
									message: revealMsg,
									chatID: tag.id)
		
		queue.message(delay: 3.sec,
									viewTime: 4.sec,
									message: chosenMsg,
									chatID: tag.id)
		
		queue.message(delay: 3.sec,
									viewTime: 4.sec,
									message: roleMsg,
									chatID: tag.id)
		
		
		
		switch kingpinChoice.role!.definition {
		
			
		/////////
		// LOSE
		// If they chose the Henchman, they lose a life.
		case .henchman:
			
			// NO LIVES
			if handle.kingpinLives <= 0 {
				let resultMsg = """
				The Kingpin looks extremely stupid in front of their fellow crime lords and loses their confidence.
				
				The Kingpin falls and the empire is in ruin.
				"""
				
				queue.message(delay: 3.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				handle.eliminatedPlayers[handle.kingpin!] = "Ran Away"
				
				queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			}
			
			// SAFE
			else {
				
				let status = useLife()
				
				let resultMsg = """
				The Kingpin looks pretty stupid in front of their fellow crime lords and offers \(kingpinChoice.name) an extravagant gift as an apologise.

				The Kingpin remains in control for now and the meeting continues.  \(status)
				"""
				
				queue.message(delay: 3.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				queue.action(delay: 3.sec, viewTime: 0.sec, action: requestPlayer)
			}
			
		/////////
		// LOSE
		// If they chose the Police, they lose immediately.
		case .police:
			
			let resultMsg = """
			Glass shatters from the ceiling as covert officers surround the building from every gap and corner.
			
			The Kingpin is dragged out of the room in cuffs by \(kingpinChoice.name).
			"""
			queue.message(delay: 3.sec,
										viewTime: 4.sec,
										message: resultMsg,
										chatID: tag.id)
			
			handle.eliminatedPlayers[handle.kingpin!] = "Arrested"
			
			queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			
		/////////
		// LOSE
		// If they chose the Spy, they lose immediately.
		case .spy:
			
			let resultMsg = """
			\(kingpinChoice.name) shoots a dozen tranquilizer darts at the Kingpin as the waiters and guards clean up the other elites.
			
			\(kingpinChoice.name) drags the Kingpin out of the room in a black bag, ready to be extradited for unknown crimes.
			"""
			
			queue.message(delay: 3.sec,
										viewTime: 4.sec,
										message: resultMsg,
										chatID: tag.id)
			
			handle.eliminatedPlayers[handle.kingpin!] = "In A Far Away Land"
			
			queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			
		/////////
		// LOSE
		// If they chose the Assistant, they lose a life
		case .assistant:
			
			// NO LIVES
			if handle.kingpinLives <= 0 {
				let resultMsg = """
				The Kingpin looks extremely stupid in front of their fellow crime lords and loses their confidence.
				
				The Kingpin falls and the empire is in ruin.
				"""
				
				queue.message(delay: 3.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				handle.eliminatedPlayers[handle.kingpin!] = "Ran Away"
				
				queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			}
				
				// SAFE
			else {
				
				let status = useLife()
				
				let resultMsg = """
				The Kingpin looks pretty stupid in front of their fellow crime lords and offers \(kingpinChoice.name) an extravagant gift as an apologise.
				
				The Kingpin remains in control for now and the meeting continues.  \(status)
				"""
				
				queue.message(delay: 3.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				queue.action(delay: 3.sec, viewTime: 0.sec, action: requestPlayer)
			}
			
		/////////
		// LOSE
		// If they chose the Henchman, they lose a life.
		case .bountyHunter:
			
			// NO LIVES
			if handle.kingpinLives <= 0 {
				let resultMsg = """
				The Kingpin looks extremely stupid in front of their fellow crime lords and loses their confidence.
				
				The Kingpin falls and the empire is in ruin.
				"""
				
				queue.message(delay: 3.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				handle.eliminatedPlayers[handle.kingpin!] = "Ran Away"
				
				queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			}
				
				// SAFE
			else {
				
				let status = useLife()
				
				let resultMsg = """
				The Kingpin looks pretty stupid in front of their fellow crime lords and offers \(kingpinChoice.name) an extravagant gift as an apologise.
				
				The Kingpin remains in control for now and the meeting continues.  \(status)
				"""
				
				queue.message(delay: 3.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				queue.action(delay: 3.sec, viewTime: 0.sec, action: requestPlayer)
			}
			
		/////////
		// LOSE
		// If they chose the Henchman, they kill them and retrieve the stolen Opals.
		case .thief:
			
			let resultMsg = """
			\(kingpinChoice.name) starts to sweat, but before they can move a muscle the Kingpin shoots them in place.
			
			\(kingpinChoice.name) collapses into their chair.
			"""
			queue.message(delay: 3.sec,
										viewTime: 4.sec,
										message: resultMsg,
										chatID: tag.id)
			
			// Declare them as dead and remove them from the player pool.
			handle.eliminatedPlayers[kingpinChoice] = "Dead"
			let index = handle.players.index(of: kingpinChoice)!
			handle.players.remove(at: index)
			
			queue.action(delay: 3.sec, viewTime: 0.sec) { self.retrieveOpals(pick: kingpinChoice) }
		
		/////////
		// WHOOPS
		case .kingpin:
			handle.circuitBreaker("Event_Interrogate - The kingpin somehow picked themselves.")
		}
		
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Consumes a life and returns a life status prompt to use.
	*/
	func useLife() -> String {
		handle.kingpinLives -= 1
		var livesPrompt = ""
		
		if handle.kingpinLives == 0 {
			livesPrompt = "(The kingpin cannot afford another mistake.)"
		} else {
			livesPrompt = "(The kingpin has \(handle.kingpinLives) chances left.)"
		}
		
		return livesPrompt
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Call this if the Kingpin found a thief.  If the Kingpin finds all the opals, the game is immediately over.
	*/
	func retrieveOpals(pick: Player) {
		
		
		// ANNOUNCE OPALS
		
		// Set the messages
		let retrieveMsg1 = """
		The Kingpin approaches \(pick.name) lifeless corpse and searches it carefully.
		"""
		
		let retrieveMsg2 = """
		The Kingpin finds \(pick.points[KingpinDefault.opal]!) Opals.
		"""
		
		// Schedule them.
		queue.message(delay: 3.sec,
									viewTime: 5.sec,
									message: retrieveMsg1,
									chatID: tag.id)
		
		queue.message(delay: 3.sec,
									viewTime: 5.sec,
									message: retrieveMsg2,
									chatID: tag.id)
		
		
		
		// OPAL DECISIONS
		
		// Schedule the Opal retrieval.
		queue.action(delay: 2.sec, viewTime: 0.sec) {
			
			let opalAmount = pick.points[KingpinDefault.opal]!
			pick.points.clearAll()
			self.handle.kingpin!.points.changeCurrency(KingpinDefault.opal, change: opalAmount)
			
			
			let thieves = self.handle.players.filter({$0.role?.definition == .thief})
			
			
			// If the Kingpin has all the opals back, end the game immediately.
			if thieves.count == 0 {
				let allThievesDead = """
				The Kingpin has recovered all the Opals, securing the future of the criminal empire.
				"""
				
				self.queue.message(delay: 3.sec,
													 viewTime: 6.sec,
													 message: allThievesDead,
													 chatID: self.tag.id)
				
				self.queue.action(delay: 3.sec, viewTime: 0.sec) {
					self.end(playerTrigger: nil, participants: nil)
				}
			}
			
			// Otherwise continue investigating.
			else {
				let thievesRemain = """
				The Vault is still missing Opals.
				
				\(pick.name)'s body is dragged out of the room and the meeting continues.
				"""
				
				self.queue.message(delay: 3.sec,
													 viewTime: 7.sec,
													 message: thievesRemain,
													 chatID: self.tag.id)
				
				self.queue.action(delay: 3.sec, viewTime: 0.sec, action: self.requestPlayer)
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	One way or another, the meeting is over but the Kingpin hasn't won.
	
	This searches through the list of players, working out any additional win conditions and setting the final winners.
	*/
	func kingpinLoses(pick: Player) {
		queue.clear()
		handle.playerRoute.resetRequest()
		
		let pickRole = pick.role!.definition
		
		
		// If the picked player was the spy or police, they immediately win.
		
		if pickRole == .police || pickRole == .spy {
			handle.winningPlayers.append(pick)
		}
		
			
		// If not, find all the thieves and see who got the most Opals, then set them as the winner
			
		else {
			let thieves = handle.players.filter( {$0.role!.definition == .thief } )
			
			var mostOpalsStolen = 0
			thieves.forEach { thief in
				let opals = thief.points[KingpinDefault.opal]!.intValue
				if mostOpalsStolen < opals { mostOpalsStolen = opals }
			}
			
			let bestThieves = handle.players.filter( { $0.points[KingpinDefault.opal]!.intValue == mostOpalsStolen } )
			handle.winningPlayers.append(contentsOf: bestThieves)
		}
		
		// If any assistants are in the game, work out if the player below them won.
		
		
		
		self.end(playerTrigger: nil, participants: nil)
		
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Decide what to do now that the Kingpin has pissed off somewhere.
	*/
	func finishEarly() {
		
	}
}
