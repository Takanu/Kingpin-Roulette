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
	
	// Present the dliemna and ask for a player selection
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

		Everyone gathers at the Kingpin's headquarters...
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
		
		// If they chose the Henchman, they lost a life
		if kingpinChoice.role!.definition == .henchman {
			
			
			
			
			
		}
		
		// Ifthey chose the Police, they lose
		if kingpinChoice.role!.definition == .police {
			
			
			
			
		}
		
		// If they chose the Spy, they lose
		if kingpinChoice.role!.definition == .spy {
			
			
			
			
		}
		
		// If they chose the Assistant, they lose
		if kingpinChoice.role!.definition == .assistant {
			
			
			
			
		}
		
		// If they chose the Assistant, they lose
		if kingpinChoice.role!.definition == .bountyHunter {
			
			
			
			
		}
		
		// If they chose the Thief, they kill them, recover their Opals and see if they recovered all of them.
		if kingpinChoice.role!.definition == .thief {
			
			
			
			
		}
		
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Call this if the Kingpin made the wrong decision.
	*/
	func badChoice(pick: Player) {
		
		
		
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Call this if the Kingpin found a thief.
	*/
	func foundThief(pick: Player) {
		
		
		
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Decide what to do now that the Kingpin has pissed off somewhere.
	*/
	func finishEarly() {
		
	}
}
