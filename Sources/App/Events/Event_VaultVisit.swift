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
	
	var eventType: EventType = KingpinDefault.eventType
    
  var eventInfo: String = "Allows each player including the Kingpin to visit the Vault."
	
	/// The number of players that haven't yet visited the vault.
	var visitorsLeft: [Player] = []
	
	/// The player currently visiting the vault.
	var vaultVisitor: Player?
	
	/// The Vault inline key, nicely wrapped into an InlineMarkup type.
	var inlineVault = MarkupInline(withButtons: Vault.inlineKey)
  
  /// Defines whether or not the first player either in order or by proxy of other players who timed out ahead, has selected and discarded a Vault item.
  var firstPlayerFinished = false
  
  
  /////////////////////////////////////////////////////////////////////////////////
  /**
  Verify that we have the required game state.
  */
  override func verify(handle: GameHandle) -> Error? {
    
    // Make sure we have the correct number of players
    if handle.players.count < KingpinDefault.minimumPlayers - 1 ||
      handle.players.count > KingpinDefault.maximumPlayers - 1 {
      return KingpinError.wrongPlayerCount
    }
    
    // Make sure we have a Kingpin
    if handle.kingpin == nil { return KingpinError.noKingpinFound }
    
    // Make sure the Vault isn't empty
    if handle.vault.roles.getItemCopies(forType: KingpinRoles.type.name) == nil { return KingpinError.noRoles }
    if handle.vault.valuables[KingpinDefault.opal] == nil { return KingpinError.noOpals }
    if handle.vault.valuables[KingpinDefault.opal]!.int != handle.startOpals { return KingpinError.wrongOpalCount }
    
    return nil
  }
	
	
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
			Unfortunately for the Kingpin, almost half of you will choose a role that will *act against the Kingpin, such as stealing \(KingpinDefault.opal.pluralisedName) or being an undercover cop*.
			"""
			
			let tutorial4 = """
			You will choose your role when you watch over the vault.

			Tap the button below to view all the possible roles that someone can choose.  (The Rogue is not available in a Standard Game).
			"""
			
			queue.message(delay: 1.sec,
										viewTime: 10.sec,
										message: tutorial1,
										chatID: tag.id)
			
			queue.message(delay: 5.sec,
										viewTime: 7.sec,
										message: tutorial2,
										chatID: tag.id)
			
			queue.message(delay: 5.sec,
										viewTime: 10.sec,
										message: tutorial3,
										chatID: tag.id)
			
			queue.message(delay: 5.sec,
										viewTime: 13.sec,
										message: tutorial4,
										markup: MarkupInline(withButtons: KingpinRoles.inlineKey),
										chatID: tag.id)
			
		}
		
		
		//////////////////////
		// INTRO
		
		var entrance1 = """
		The new Kingpin gathers everyone and entrusts you the duties of watching over the Vault in a specific order.

		👑 \(handle.kingpin!.name) 👑
		
		**Vault Watch Schedule:**
		"""
		
		for player in handle.players {
			entrance1 += "\n😇  \(player.name)"
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
				Before leaving the Vault's protection to everyone, the Kingpin decides to *personally make note of the valuables inside*.
				"""
				
				kingpinVisit2 = """
				The Kingpin studies the Vault carefully.

				(\(handle.kingpin!.name), you have 25 seconds to memorise the available roles and Opals)
				"""
				
				queue.message(delay: 2.sec,
											viewTime: 7.sec,
											message: kingpinVisit1,
											markup: nil,
											chatID: tag.id)
			}
			
			else {
				kingpinVisit2 = """
				Before leaving the Vault's protection to everyone, the Kingpin decides to *personally make note of the valuables inside*.

				(\(handle.kingpin!.name) has 25 seconds to view this information, remember it well)
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
			
			(Take an item from the Vault to be your role)
			"""
			
      let visitWarning = """
      \(vaultVisitor!.name), you have \(Int(KingpinDefault.watchWarningTime.rawValue)) seconds left to take an item from the Vault.
      """
      
			queue.message(delay: 2.sec,
										viewTime: 9.sec,
										message: otherVisit,
										markup: inlineVault,
										chatID: tag.id)
      
      queue.message(delay: KingpinDefault.watchLengthTime,
                    viewTime: 0.sec,
                    message: visitWarning,
                    markup: inlineVault,
                    chatID: tag.id)
			
      queue.action(delay: KingpinDefault.watchWarningTime,
                   viewTime: 0.sec,
                   action: watcherTimeout)
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
		else if item.itemType == KingpinDefault.opalItemTag {
			
			let opalsStolen = item as! OpalUnit
			let opalValue = opalsStolen.value.int
      handle.vault.valuables.deduct(type: opalsStolen.pointType, amount: .int(opalValue))
			
      vaultVisitor!.points.add(type: KingpinDefault.opal, amount: opalsStolen.value)
			vaultVisitor!.role = KingpinRoles.thief
		}
		
		else {
      abort(KingpinError.vaultFoundIncorrectItem)
			return
		}
		
		handle.vault.resetRequest()
		queue.clear()
		
		// If the first visitor is on patrol, they also need to remove an item.
		
    if firstPlayerFinished == false {
			queue.action(delay: 3.sec,
									 viewTime: 0.sec,
									 action: removeVaultItem)
			return
		}
		
		
		// If there's no leftover items or opals OR the last person is taking their turn, add the associate role.
		
		if (handle.vault.roles.getItemCount(forType: KingpinRoles.type) == 0 && handle.vault.valuables[KingpinDefault.opal]!.int == 0)
			|| visitorsLeft.count == 1 {
			
			if handle.vault.roles.hasItem(KingpinRoles.accomplice) == false {
				handle.vault.roles.add([KingpinRoles.accomplice])
        handle.vault.roles.editStack(ofItem: KingpinRoles.accomplice, makeStackUnlimited: true)
			}
		}
		
		// If one person is left and the tutorial is on, explain what they can have access to.
		
		if visitorsLeft.count == 1 && handle.useTutorial == true {
			
			let accompliceNotice = """
			If you ever find the Vault with no Opals or roles left to take, or if you are the last person to watch the Vault, *you will have access to the Accomplice role, whose task is to help the Thieves succeed*.
			"""
			
			queue.message(delay: 0.sec,
										viewTime: 7.sec,
										message: accompliceNotice,
										chatID: tag.id)
		}
		
		
		// Otherwise, complete the visit.
		
		queue.action(delay: 3.sec,
								 viewTime: 0.sec,
								 action: completeOtherVisit)
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Requested from the first player, after they pick an item to keep.
	*/
	func removeVaultItem() {
		queue.clear()
		handle.vault.newRequest(newViewer: vaultVisitor!, includeOpals: false, next: receiveRemovalSelection)
    firstPlayerFinished = true
		
		let otherVisit = """
		To avoid being identified, \(vaultVisitor!.name) takes something else from the vault and destroys it...
		
		(Take an item from the Vault to be removed from the game)
		"""
    
    let removalWarning = """
    \(vaultVisitor!.name), you have \(Int(KingpinDefault.watchWarningTime.rawValue)) seconds left to *destroy* an item from the Vault.
    """
		
		queue.message(delay: 2.sec,
									viewTime: 7.sec,
									message: otherVisit,
									markup: inlineVault,
									chatID: tag.id)
    
    queue.message(delay: KingpinDefault.watchLengthTime,
                  viewTime: 0.sec,
                  message: removalWarning,
                  markup: inlineVault,
                  chatID: tag.id)
    
    queue.action(delay: KingpinDefault.watchWarningTime,
                 viewTime: 0.sec,
                 action: watcherTimeout)
		
	}
	
	func receiveRemovalSelection(item: ItemRepresentible) {
		queue.clear()
		
		// Remove the item from the valuables or roles list.
		if handle.vault.roles.removeItem(item) != nil {
			queue.action(delay: 2.sec,
									 viewTime: 0.sec,
									 action: completeOtherVisit)
			return
		}
		
		else {
      abort(KingpinError.watcherRemovedNonRoleItem)
			return
		}
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Complete the Kingpin's visit.
	*/
	func completeKingpinVisit() {
		self.queue.clear()
		handle.vault.resetRequest()
		
		let vaultFinishMsg = """
		The Kingpin finishes their inspection and passes on the responsibility to everyone else. while they take care of some important business.
		"""
		
		queue.message(delay: 0.sec,
									viewTime: 5.sec,
									message: vaultFinishMsg,
									chatID: tag.id)
		
		
		//////////////////////
		// TUTORIAL
		// If the tutorial is on, build up the scenario so people know what to expect.
		if handle.useTutorial == true {
			
			let observePointerMsg = """
			As it becomes your turn to watch the vault, it's important to make note of what's inside.

			*Knowing whats left in the Vault can give you hints as to what the role of other players is, making it easier to achieve your own goals.*
			"""
			
			queue.message(delay: 0.sec,
										viewTime: 7.sec,
										message: observePointerMsg,
										chatID: tag.id)
			
		}
		
		
		queue.action(delay: 3.sec,
								 viewTime: 0.sec,
								 action: visitVault)
		
	}
	
	/**
	Complete another player's visit.
	*/
	func completeOtherVisit() {
		queue.clear()
		handle.vault.resetRequest()
		
		let vaultFinishMsg = """
		\(vaultVisitor!.name)'s time to watch the vault is now over.
		"""
		
		request.async.sendMessage(vaultFinishMsg,
															markup: nil,
															chatID: tag.id)
		
		queue.action(delay: 3.sec,
								 viewTime: 0.sec,
								 action: visitVault)
		
	}
  
  /**
  Mark the currently active vault watcher as being killed in an accident, removing them from the game and
  immediately passing watch to the next player.
  */
  func watcherTimeout() {
    queue.clear()
    handle.vault.resetRequest()
    
    let vaultTimeoutMsg = """
    Before \(vaultVisitor!.name) could look inside the vault, they experience an "accident" while on watch.
    
    \(vaultVisitor!.name) is never seen again...
    """
    
    vaultVisitor!.flair.add(KingpinFlair.accident)
    request.async.sendMessage(vaultTimeoutMsg,
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
		queue.clear()
		
		// Remove the accomplice from the vault
    handle.vault.roles.editStack(ofItem: KingpinRoles.accomplice, makeStackUnlimited: false)
    handle.vault.roles.removeItem(KingpinRoles.accomplice)
		
		// Exit
		queue.action(delay: 5.sec,
								 viewTime: 0.sec) {
			
			self.end(playerTrigger: nil, participants: nil)
		}
		
	}
}
