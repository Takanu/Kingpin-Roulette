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
	
	// Present the dliemna and ask for a player selection
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
			
			"""
			
			let tutorial2 = """
			The vault is watched over on a regular basis by the Kingpin's most loyal partners in crime.
			"""
			
			let tutorial3 = """
			The Kingpin however is about to find out that their trust was greatly mis-placed.
			"""
			
			queue.message(delay: 1.sec,
										viewTime: 5.sec,
										message: tutorial1,
										chatID: tag.id)
			
			queue.message(delay: 5.sec,
										viewTime: 5.sec,
										message: tutorial2,
										chatID: tag.id)
			
			queue.message(delay: 5.sec,
										viewTime: 5.sec,
										message: tutorial3,
										chatID: tag.id)
			
		}
		
		
		//////////////////////
		// INTRO
		var entrance1 = """
		With the new Kingpin established, they gather the most loyal partners in crime to keep watch over the Vault.

		👑 \(handle.kingpin!.name) 👑
		
		"""
		
		for player in handle.players {
			entrance1 += "\n\(player.name)"
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
	
	func visitVault() {
		
		
		// If we've been called but no-one is left to visit the vault, exit.
		if visitorsLeft.count == 0 {
			concludeVisit()
			return
		}
		
		// Go through each player in the list and let them look and choose.
		vaultVisitor = visitorsLeft.removeFirst()
		
		// If they are the kingpin, just cycle back here after 20 seconds.
		if vaultVisitor!.role?.definition == .kingpin {
			handle.vault.newRequest(newViewer: vaultVisitor!, next: nil)
			
			let kingpinVisit = """
			Before leaving the Vault's protection to everyone else, the Kingpin decides to personally make note of the valuables inside.

			(you have 25 seconds to inspect the Vault, memorise everything it contains).
			"""
			
			request.async.sendMessage(kingpinVisit,
																markup: inlineVault,
																chatID: tag.id)
			
			queue.action(delay: 25.sec,
									 viewTime: 0.sec,
									 action: completeKingpinVisit)
			
		}
		
		// If not, send a different message with a request callback.
		else {
			handle.vault.newRequest(newViewer: vaultVisitor!, next: receiveSelection)
			
			let otherVisit = """
			It is \(vaultVisitor!.name)'s turn to protect the Vault.

			(you have 30 seconds to pick an item from the Vault)
			"""
			
			request.async.sendMessage(otherVisit,
																markup: inlineVault,
																chatID: tag.id)
			
			queue.action(delay: 30.sec,
									 viewTime: 0.sec,
									 action: completeOtherVisit)
		}
		
		
	}
	
	
	func receiveSelection(item: ItemRepresentible) {
		
		
		// Remove the item from the valuables or roles list.
		if let item = handle.vault.roles.removeItem(item) {
			
			let role = item as! KingpinRole
			vaultVisitor!.role = role
		}
		
		// If it's not a role, convert it to an opal and deduct the amount from the valuables.
		if item.type == KingpinDefault.opalItemTag {
			
			let opalsStolen = item as! OpalUnit
			let opalValue = opalsStolen.unit.value.intValue
			handle.vault.valuables.changeCurrency(opalsStolen.unit.type, change: .int(opalValue * -1))
			
			vaultVisitor!.points.addCurrency(KingpinDefault.opal, initialAmount: opalsStolen.unit.value)
			vaultVisitor!.role = KingpinRoles.thief
		}
		
		else {
			print("\(#line) \(#function) - Item was found, but couldn't be given to the player.")
			return
		}
		
		handle.vault.resetRequest()
		queue.clear()
		queue.action(delay: 3.sec,
								 viewTime: 0.sec,
								 action: completeOtherVisit)
	}
	
	
	func completeKingpinVisit() {
		self.queue.clear()
		handle.vault.resetRequest()
		
		let vaultFinish = """
		The Kingpin gets a good look at the Vault, and then passes on the responsibility to his most trusted allies.
		"""
		
		request.async.sendMessage(vaultFinish,
															markup: nil,
															chatID: tag.id)
		
		
		
		//////////////////////
		// TUTORIAL
		// If the tutorial is on, build up the scenario so people know what to expect.
		if handle.useTutorial == true {
			
		}
		
		queue.action(delay: 5.sec,
								 viewTime: 0.sec,
								 action: visitVault)
		
	}
	
	func completeOtherVisit() {
		self.queue.clear()
		handle.vault.resetRequest()
		
		let vaultFinish = """
		\(vaultVisitor!.name) has finished keeping watch of the vault.
		"""
		
		request.async.sendMessage(vaultFinish,
															markup: nil,
															chatID: tag.id)
		
		queue.action(delay: 5.sec,
								 viewTime: 0.sec,
								 action: visitVault)
		
	}
	
	func concludeVisit() {
		
		queue.action(delay: 5.sec,
								 viewTime: 0.sec) {
			
			self.end(playerTrigger: nil, participants: nil)
		}
		
	}
}
