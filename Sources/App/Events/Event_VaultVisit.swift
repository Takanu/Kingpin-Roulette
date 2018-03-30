//
//  Event_PassTheBox.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class Event_VaultVisit: KingpinEvent, EventRepresentible {
	
	var eventName: String = "Vault Visit"
	
	var eventType: EventType = EventType(name: "Kingpin Event",
																			 symbol: "👑",
																			 pluralisedName: "Kingpin Event",
																			 description: "oh hey, it's an event.")
	
	/// The number of players that haven't yet visited the vault.
	var visitorsLeft: [Player] = []
	
	/// The player currently visiting the vault.
	var vaultVisitor: Player?
	
	/// The Vault inline key, nicely wrapped into an InlineMarkup type.
	var inlineVault = MarkupInline(withButtons: Vault.inlineKey)
	
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Present the dliemna and ask for a player selection
	*/
	override func execute() {
		
		/////////////////////
		// STATE SETUP
		
		// Mix up the character order for everyone that isn't the Kingpin.
		var tempPlayerContainer = handle.players
		var newPlayerOrder: [Player] = []
		
		while tempPlayerContainer.count != 0 {
			newPlayerOrder.append(tempPlayerContainer.popRandom()!)
		}
		
		handle.players = newPlayerOrder
		
		// Setup the visitor queue with the kingpin
		visitorsLeft = newPlayerOrder
		visitorsLeft.insert(handle.kingpin!, at: 0)
		
		
		
		//////////////////////
		// TUTORIAL
		
		// If the tutorial is on, build up the scenario so people know what to expect.
		if handle.useTutorial == true {
			let tutorial1 = """
			With the leadership crisis fixed, the Kingpin's first order of business is deciding who will watch over the Vault.

			The Vault is a main source of the organisation's riches and power, and contains within it a mythical resource known as \(KingpinDefault.opal.pluralisedName).
			"""
			
			let tutorial2 = """
			With no-one else to trust, the Kingpin turns to you to watch over the Vault in order.
			"""
			
			let tutorial3 = """
			Much like the previous Kingpin however, they are about to find out that their trust was greatly misplaced.

			Almost half of you will choose a *role* that don't involve helping the Kingpin such as stealing \(KingpinDefault.opal.pluralisedName) or being an undercover cop.
			"""
			
			let tutorial4 = """
			The things you can take from the Vault will be shown when it's your turn to watch over it.
			"""
			
			queue.message(delay: 1.sec,
										viewTime: 10.sec,
										message: tutorial1,
										chatID: tag.id)
			
			queue.message(delay: 5.sec,
										viewTime: 6.sec,
										message: tutorial2,
										chatID: tag.id)
			
			queue.message(delay: 5.sec,
										viewTime: 9.sec,
										message: tutorial3,
										chatID: tag.id)
			
			queue.message(delay: 5.sec,
										viewTime: 9.sec,
										message: tutorial3,
										chatID: tag.id)
			
		}
		
		
		//////////////////////
		// INTRO
		
		var entrance1 = """
		The new Kingpin gathers the elite circle and entrusts duties of watching over the Vault in a specific order.

		👑 \(handle.kingpin!.name) 👑
		
		"""
		
		for player in handle.players {
			entrance1 += "\n>  \(player.name)"
		}
		
		queue.message(delay: 1.sec,
									viewTime: 7.sec,
									message: entrance1,
									chatID: tag.id)
		
		queue.action(delay: 3.sec, viewTime: 0.sec) {
			self.queue.clear()
			self.visitVault()
		}
		
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Attempt to visit the vault, selecting the next person on the list of visitors and asking them to make a choice from the vault.
	*/
	func visitVault() {
		
		
		// If we've been called but no-one is left to visit the vault, exit.
		if visitorsLeft.count == 0 {
			concludeVisit()
			return
		}
		
		// Go through each player in the list and let them look and choose.
		vaultVisitor = visitorsLeft.removeFirst()
		
		
		//////////////////////
		// KINGPIN
		
		// If they are the kingpin, just cycle back here after 20 seconds.
		if vaultVisitor!.role?.definition == .kingpin {
			handle.vault.newRequest(newViewer: vaultVisitor!, includeOpals: true, next: nil)
			
			var kingpinVisit1 = ""
			var kingpinVisit2 = ""
			
			if handle.useTutorial == true {
				kingpinVisit1 = """
				Before leaving the Vault's protection to their elite circle, the Kingpin decides to personally make note of the valuables inside.
				"""
				
				kingpinVisit2 = """
				The Kingpin studies this information and the Vault carefully.

				(you have 25 seconds to view the available roles and , remember it!).
				"""
				
				queue.message(delay: 2.sec,
											viewTime: 7.sec,
											message: kingpinVisit1,
											markup: nil,
											chatID: tag.id)
			}
			
			else {
				kingpinVisit2 = """
				The Kingpin receives an anonymous tip that the elite circle has hidden agendas.  They study the information and the vault carefully.

				(\(handle.kingpin!.name) has 25 seconds to view this information, remember it!).
				"""
				
			}
			
			queue.message(delay: 2.sec,
										viewTime: 9.sec,
										message: kingpinVisit2,
										markup: inlineVault,
										chatID: tag.id)
			
			queue.action(delay: 25.sec,
									 viewTime: 0.sec,
									 action: completeKingpinVisit)
			
		}
			
			
		//////////////////////
		// OTHER PLAYERS
		
		// If not, send a different message with a request callback.
		else {
			handle.vault.newRequest(newViewer: vaultVisitor!, includeOpals: true, next: receiveSelection)
			
			let otherVisit = """
			It is \(vaultVisitor!.name)'s turn to watch over the Vault.
			
			(Take an item from the Vault)
			"""
			
			queue.message(delay: 2.sec,
										viewTime: 9.sec,
										message: otherVisit,
										markup: inlineVault,
										chatID: tag.id)
			
			/// The player has to make a move, do not move on until they have chosen.
//			queue.action(delay: 30.sec,
//									 viewTime: 0.sec,
//									 action: completeOtherVisit)
		}
		
		
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Receive a selection a player has made and ask the next player to visit the vault.
	*/
	func receiveSelection(item: ItemRepresentible) {
		
		// Remove the item from the valuables or roles list.
		if let item = handle.vault.roles.removeItem(item) {
			
			let role = item as! KingpinRole
			vaultVisitor!.role = role
		}
		
		// If it's not a role, convert it to an opal and deduct the amount from the valuables.
		else if item.type == KingpinDefault.opalItemTag {
			
			let opalsStolen = item as! OpalUnit
			let opalValue = opalsStolen.unit.value.intValue
			handle.vault.valuables.changeCurrency(opalsStolen.unit.type, change: .int(opalValue * -1))
			
			vaultVisitor!.points.addCurrency(KingpinDefault.opal, initialAmount: opalsStolen.unit.value)
			vaultVisitor!.role = KingpinRoles.thief
		}
		
		else {
			handle.circuitBreaker("Event_VaultVisit - Item was found, but couldn't be given to the player.")
			return
		}
		
		handle.vault.resetRequest()
		queue.clear()
		
		
		// If the first visitor is on patrol, they also need to remove an item.
		
		if visitorsLeft.count == handle.players.count - 1 {
			queue.action(delay: 3.sec,
								 viewTime: 0.sec,
								 action: removeVaultItem)
		}
			
		// If there's no leftover items or opals OR the last person is taking their turn, add the associate role.
		
		if (handle.vault.roles.getItemCount(forType: KingpinRoles.type) == 0 && handle.vault.valuables[KingpinDefault.opal]?.intValue ?? 0 == 0)
			|| visitorsLeft.count == 1 {
			
			handle.vault.roles.addItems([KingpinRoles.accomplice])
			handle.vault.roles.modifyStack(ofItem: KingpinRoles.accomplice, useUnlimitedStack: true)
		}
		
		// Complete the visit.
			
		else {
			queue.action(delay: 3.sec,
									 viewTime: 0.sec,
									 action: completeOtherVisit)
		}
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Requested from the first player, after they pick an item to keep.
	*/
	func removeVaultItem() {
		queue.clear()
		handle.vault.newRequest(newViewer: vaultVisitor!, includeOpals: false, next: receiveRemovalSelection)
		
		let otherVisit = """
		To avoid being identified, \(vaultVisitor!.name) removes something else from the vault...
		"""
		
		queue.message(delay: 2.sec,
									viewTime: 7.sec,
									message: otherVisit,
									markup: inlineVault,
									chatID: tag.id)
		
	}
	
	func receiveRemovalSelection(item: ItemRepresentible) {
		
		// Remove the item from the valuables or roles list.
		if handle.vault.roles.removeItem(item) == nil {
			
			let opalsStolen = item as! OpalUnit
			let opalValue = opalsStolen.unit.value.intValue
			handle.vault.valuables.changeCurrency(opalsStolen.unit.type, change: .int(opalValue * -1))
		}
		
		queue.action(delay: 2.sec,
								 viewTime: 0.sec,
								 action: completeOtherVisit)
		
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Complete the Kingpin's visit.
	*/
	func completeKingpinVisit() {
		self.queue.clear()
		handle.vault.resetRequest()
		
		let vaultFinish = """
		The Kingpin finishes their inspection and passes on the responsibility to their most trusted allies.
		"""
		
		request.async.sendMessage(vaultFinish,
															markup: nil,
															chatID: tag.id)
		
		
		
		//////////////////////
		// TUTORIAL
		// If the tutorial is on, build up the scenario so people know what to expect.
		if handle.useTutorial == true {
			
		}
		
		queue.action(delay: 3.sec,
								 viewTime: 0.sec,
								 action: visitVault)
		
	}
	
	/**
	Complete another player's visit.
	*/
	func completeOtherVisit() {
		self.queue.clear()
		handle.vault.resetRequest()
		
		let vaultFinish = """
		\(vaultVisitor!.name)'s time to watch the vault is now over.
		"""
		
		request.async.sendMessage(vaultFinish,
															markup: nil,
															chatID: tag.id)
		
		queue.action(delay: 3.sec,
								 viewTime: 0.sec,
								 action: visitVault)
		
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Conclude the visit and exit.
	*/
	func concludeVisit() {
		
		queue.action(delay: 5.sec,
								 viewTime: 0.sec) {
			
			self.end(playerTrigger: nil, participants: nil)
		}
		
	}
}
