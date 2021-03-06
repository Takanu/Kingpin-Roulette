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
	
	var eventType: EventType = KingpinDefault.eventType
    
  var eventInfo: String = "Allows the Kingpin to interrogate and choose suspects in the Opal theft."
	
	
	let revealMsg = """
	The Kingpin stands up in front of the elites and makes a DECLARATION!
	"""
  
  var chosenPlayer: Player?
	
	var playersLeft: [Player] = []
  
  let rogueKey = MarkupInlineKey(fromCallbackData: "rogue_shot", text: "(Rogue) Shoot Suspect")!
  var rogueInline: MarkupInline {
    return MarkupInline(withButtons: rogueKey)
  }
  
  
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
    
    // Make sure each player has a role
    // ... or not, players might timeout.
//    for player in handle.players {
//      if player.role == nil { return KingpinError.missingPlayerRoles }
//    }
    
    return nil
  }
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Start the interrogation proceedings!
	*/
	override func execute() {
    
		playersLeft = handle.players.filter({
      $0.flair.find(KingpinFlair.accident, compareContents: false) == false &&
      $0.flair.find(KingpinFlair.dead, compareContents: false) == false
    })
    
    ///////////////////////////
    // NO THIEVES FOUND
    let thieves = handle.players.filter( { $0.role?.definition == .thief &&
      $0.flair.flairs[KingpinFlair.statusCategory] == nil
    } )
    
    if thieves.count == 0 {
      
      let noThieves1 = """
      Everyone has finished their first watch, and the Kingpin returns to see that the Vault is... exactly as they left it?
      """
      
      let noThieves2 = """
      Satisfied, the Kingpin continues running the criminal underworld in confidence.

      With nothing to fight over, the Elites wonder what they were even supposed to do.

      (Nobody stole any opals!)
      """
      
      handle.kingpin!.flair.add(KingpinFlair.winner)
      
      // Send a message to announce the state and give the Kingpin generous time to choose...
      queue.message(delay: 1.sec,
                    viewTime: 6.sec,
                    message: noThieves1,
                    chatID: tag.id)
      
      queue.message(delay: 1.sec,
                    viewTime: 9.sec,
                    message: noThieves2,
                    chatID: tag.id)
      
      self.queue.action(delay: 3.sec, viewTime: 0.sec) {
        self.end(playerTrigger: nil, participants: nil)
      }
      
      return
    }
		
		
		///////////////////////////
		// INTRO
		
		// Pass vault control entirely to the Kingpin
		let interrogate1 = """
		Everyone has finished their first watch, and the Kingpin returns to see that the Vault is not as they left it.
		"""
		
		let interrogate2 = """
		Furious, the Kingpin gathers their Vault watchers in an attempt to work out who stole the Kingpin's precious Opals.

		Everyone gathers at the Kingpin's headquarters for the most serious meeting of their lives.
		"""
		
		
		// Send a message to announce the state and give the Kingpin generous time to choose...
		queue.message(delay: 1.sec,
									viewTime: 6.sec,
									message: interrogate1,
									chatID: tag.id)
		
		queue.message(delay: 1.sec,
									viewTime: 9.sec,
									message: interrogate2,
									chatID: tag.id)
		
		
		///////////////////////////
		// TUTORIAL
		if handle.useTutorial {
			let interrogateTut1 = """
			In this meeting, the Kingpin's goal is to *recover all their Opals back* by accusing players they think stole them.  Once accussed, that person's role will be revealed to all.

			(\(handle.kingpin!.name), grill your partners in crime and figure out who's who).
			"""
			
			var interrogateTut2 = """
			If the Kingpin ever accuses someone who didn't steal any Opals, a gift will be given to them as an apology.

			If the Kingpin runs out of gifts, they *will lose the confidence of the Vault watchers and will immediately lose, ending the game.*
			"""
			
			var interrogateTut3 = ""
			
			if handle.playerCount < 8 {
				interrogateTut3 = """
				For 6 or 7 player games the Kingpin won't normally receive a present, but for this game the Kingpin will have *one gift*, allowing them to make a single mistake.
				"""
			} else {
				interrogateTut2 = """
				In this game, the Kingpin has *\(handle.kingpinLives) gifts* to use when making mistakes.
				"""
			}
			
			let interrogateTut4 = """
			If the Kingpin ever loses (and didn't accuse a *Spy* or *Police Officer*) the watcher who stole the most Opals wins.
			"""
			
			queue.message(delay: 1.sec,
										viewTime: 10.sec,
										message: interrogateTut1,
										chatID: tag.id)
			
			queue.message(delay: 1.sec,
										viewTime: 8.sec,
										message: interrogateTut2,
										chatID: tag.id)
			
			queue.message(delay: 1.sec,
										viewTime: 8.sec,
										message: interrogateTut3,
										chatID: tag.id)
			
			queue.message(delay: 1.sec,
										viewTime: 6.sec,
										message: interrogateTut4,
										chatID: tag.id)
			
		}
		
		// Build the vault once more for the Kingpin.
		handle.vault.newRequest(newViewer: handle.kingpin!, includeOpals: true, next: nil)
		
		
		// Request a player selection.
		queue.action(delay: 3.sec, viewTime: 0.sec, action: requestPlayer)
		
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Ask the Kingpin to make a new selection.
	*/
	func requestPlayer() {
		queue.clear()
		handle.kingpin?.playerRoute.enabled = true
    chosenPlayer = nil
    
    playersLeft = handle.players.filter({
      $0.flair.find(KingpinFlair.accident, compareContents: false) == false &&
        $0.flair.find(KingpinFlair.dead, compareContents: false) == false &&
        $0.flair.find(KingpinFlair.giftReceived, compareContents: false) == false
    })
		
		///////////////////////////
		// SETUP
		// Give the kingpin the ability to accuse a player
		handle.playerRoute.newRequest(selectors: [handle.kingpin!],
																	targets: playersLeft,
																	includeSelf: false,
																	includeNone: false,
																	next: receivePlayerSelection,
																	anonymiser: nil)
		
		// Build text based on lives
		var livesText = ""
		if handle.kingpinLives > 0 {
			livesText = "(You have \(handle.kingpinLives) gifts)"
		} else {
			livesText = "(You have no gifts, choose carefully...)"
		}
		
		// Set the messages
		let reminder1 = """
		\(buildPlayerList())
		
		(\(handle.kingpin!.name), you have 5 minutes to decide who out of your fellow crime lords you think has stolen your Opals)

		\(livesText)
		"""
		
		let reminder2 = """
		\(buildPlayerList())
		
		(\(handle.kingpin!.name), you have \(Int(KingpinDefault.kingpinInterrogationFirstWarning.rawValue)) seconds left to make a choice)
		"""
		
		let reminder3 = """
		\(buildPlayerList())
		
		(\(handle.kingpin!.name), you have \(Int(KingpinDefault.kingpinInterrogationSecondWarning.rawValue)) seconds left to make a choice)
		"""
		
		let reminder4 = """
		\(buildPlayerList())
		
		(\(handle.kingpin!.name), you have \(Int(KingpinDefault.kingpinInterrogationLastWarning.rawValue)) seconds left to make a choice)
		"""
		
		// Build the inline response.
		let inline = MarkupInline()
		let vaultKey = MarkupInlineKey(fromInlineQueryCurrent: Vault.inlineKey.data, text: "Check Role/View Vault")
		if handle.useTutorial == true {
			inline.addRow(sequence: KingpinRoles.inlineKey)
		}
		inline.addRow(sequence: vaultKey)
		inline.addRow(sequence: Player.inlineKey)
		
		
		
		
		// Setup the timers
		let firstWarnTime = Int(KingpinDefault.kingpinInterrogationTime.rawValue - KingpinDefault.kingpinInterrogationFirstWarning.rawValue)
		let secondWarnTime = Int(KingpinDefault.kingpinInterrogationFirstWarning.rawValue - KingpinDefault.kingpinInterrogationSecondWarning.rawValue)
		let thirdWarnTime = Int(KingpinDefault.kingpinInterrogationSecondWarning.rawValue - KingpinDefault.kingpinInterrogationLastWarning.rawValue)
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
		
		self.queue.message(delay: thirdWarnTime.sec,
											 viewTime: 0.sec,
											 message: reminder4,
											 markup: inline,
											 chatID: self.tag.id)
		
		self.queue.action(delay: finishTime.sec,
											viewTime: 0.sec,
											action: self.finishEarly)
		
	}

	/**
	Builds and returns the player order.
	*/
	func buildPlayerList() -> String {
		
		var result = """
		👑 \(handle.kingpin!.name) 👑
		
		**Vault Watch Schedule:**
		"""
		
		for player in handle.players {
      var icon = ""
      
      if player.flair.find(KingpinFlair.accident, compareContents: false) {
        icon = "💥"
      }
      
      else if player.flair.find(KingpinFlair.dead, compareContents: false) {
        icon = "☠️"
      }
        
      else if player.flair.find(KingpinFlair.giftReceived, compareContents: false) {
        icon = "🎁"
      }
      
      else {
        icon = "😇"
      }
			
			result += "\n\(icon)  \(player.name)"
		}
		
		return result
	}
	
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Receive the Kingpin's selection and decide what to do with it.
	*/
	func receivePlayerSelection() {
		
		queue.clear()
		handle.kingpin?.playerRoute.enabled = false
		
		// Get the Kingpin's choice
		let result = handle.playerRoute.getResults()
		handle.playerRoute.resetRequest()
		
		if result.count == 0 {
			abort(KingpinError.noPlayerSelectionTargets)
			return
		}
		
		if result[0].choice == nil {
			abort(KingpinError.noPlayerReceived)
			return
		}
		
    // ASSIGN CHOICE
    
		let kingpinChoice = result[0].choice! as! Player
    chosenPlayer = kingpinChoice
		
    
		// Buffer padding for consistency
    
		queue.action(delay: 1.sec, viewTime: 0.sec, action: { })
		
		
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
    
    ///////////////////////////
    // ROGUE REVEAL
    
    if handle.gameMode == .rogue {
      let rogueChosenMsg = """
      \(kingpinChoice.name) name is declared.  They rise from their seat...
      """
      
      queue.message(delay: 1.sec,
                    viewTime: 5.sec,
                    message: revealMsg,
                    chatID: tag.id)
      
      // SHOOT WINDOW
      queue.action(delay: 3.sec, viewTime: 4.sec) {
        let shootRoute = RouteListen(name: "rouge_shoot",
                                     pattern: self.rogueKey.data,
                                     type: .callbackQuery,
                                     action: self.rogueShot)
        
        self.baseRoute[["event"]]?.addRoutes(shootRoute)
        
        let sentMessage = self.request.sync.sendMessage(rogueChosenMsg,
                                                        markup: self.rogueInline,
                                                        chatID: self.tag.id)
        
        self.storedMessages[self.rogueKey.data] = sentMessage
      }
      
			
      // WINDOW MISSED
      queue.action(delay: KingpinDefault.rogueHoldTime, viewTime: 4.sec) {
        self.baseRoute[["event"]]?.clearAll()
				
				self.queue.message(delay: 0.sec,
											viewTime: 5.sec,
											message: roleMsg,
											chatID: self.tag.id)
        
        if let lastMsg = self.storedMessages[self.rogueKey.data] {
          self.request.sync.editMessage(lastMsg.text!,
                                        messageID: lastMsg.tgID,
                                        inlineMessageID: nil,
                                        markup: nil,
                                        chatID: self.tag.id)
        }
        
        self.revealRole(kingpinChoice)
      }
			
			
    }
    
    ///////////////////////////
    // NO ROGUE REVEAL
    else {
      queue.message(delay: 1.sec,
                    viewTime: 5.sec,
                    message: revealMsg,
                    chatID: tag.id)
      
      queue.message(delay: 3.sec,
                    viewTime: 4.sec,
                    message: chosenMsg,
                    chatID: tag.id)
      
      queue.message(delay: 1.sec,
                    viewTime: 4.sec,
                    message: roleMsg,
                    chatID: tag.id)
      
      queue.action(delay: 1.sec, viewTime: 4.sec) {
        self.revealRole(kingpinChoice)
      }
    }
  }
		
		
  /////////////////////////////////////////////////////////////////////////////////
  /**
  Receive the Kingpin's selection and decide what to do with it.
  */
  func revealRole(_ kingpinChoice: Player) {
		
		switch kingpinChoice.role!.definition {
		
			
		/////////
		// LOSE
		// If they chose the Henchman, they lose a life.
		case .elite:
			
			// NO LIVES
			if handle.kingpinLives <= 0 {
				let resultMsg = """
				The Kingpin looks extremely stupid in front of their fellow crime lords and loses their confidence.
				
				The Kingpin falls and the empire is in ruin.
				"""
				
				queue.message(delay: 2.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				handle.kingpin!.flair.add(withName: "Ran Away", category: KingpinFlair.statusCategory)
				
				queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			}
			
			// SAFE
			else {
				
				let status = useLife()
        kingpinChoice.flair.add(KingpinFlair.giftReceived)
				
				let resultMsg = """
				The Kingpin looks pretty stupid in front of their fellow crime lords and offers \(kingpinChoice.name) an extravagant gift to apologise.

				The Kingpin remains in control for now and the meeting continues.  \(status)
				"""
				
				queue.message(delay: 2.sec,
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
			queue.message(delay: 2.sec,
										viewTime: 4.sec,
										message: resultMsg,
										chatID: tag.id)
			
			handle.kingpin!.flair.add(withName: "Arrested", category: KingpinFlair.statusCategory)
			
			queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			
		/////////
		// LOSE
		// If they chose the Spy, they lose immediately.
		case .spy:
			
			let resultMsg = """
			\(kingpinChoice.name) shoots a dozen tranquilizer darts at the Kingpin as the waiters and guards clean up the other elites.
			
			\(kingpinChoice.name) drags the Kingpin out of the room in a black bag, ready to be extradited for unknown crimes.
			"""
			
			queue.message(delay: 2.sec,
										viewTime: 4.sec,
										message: resultMsg,
										chatID: tag.id)
			
			handle.kingpin!.flair.add(withName: "In A Far Away Land", category: KingpinFlair.statusCategory)
			
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
				
				queue.message(delay: 2.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				handle.kingpin!.flair.add(withName: "Ran Away", category: KingpinFlair.statusCategory)
				
				queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			}
				
			// SAFE
			else {
				
				let status = useLife()
        kingpinChoice.flair.add(KingpinFlair.giftReceived)
				
				let resultMsg = """
				The Kingpin looks pretty stupid in front of their fellow crime lords and offers \(kingpinChoice.name) an extravagant gift to apologise.
				
				The Kingpin remains in control for now and the meeting continues.  \(status)
				"""
				
				queue.message(delay: 2.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				queue.action(delay: 3.sec, viewTime: 0.sec, action: requestPlayer)
			}
			
		/////////
		// LOSE
		// If they chose the Bounty Hunter, they lose a life.
		case .rogue:
			
			// NO LIVES
			if handle.kingpinLives <= 0 {
				let resultMsg = """
				The Kingpin looks extremely stupid in front of their fellow crime lords and loses their confidence.
				
				The Kingpin falls and the empire is in ruin.
				"""
				
				queue.message(delay: 2.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				handle.kingpin!.flair.add(withName: "Ran Away", category: KingpinFlair.statusCategory)
				
				queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			}
				
				// SAFE
			else {
				
				let status = useLife()
        kingpinChoice.flair.add(KingpinFlair.giftReceived)
				
				let resultMsg = """
				The Kingpin looks pretty stupid in front of their fellow crime lords and offers \(kingpinChoice.name) an extravagant gift to apologise.
				
				The Kingpin remains in control for now and the meeting continues.  \(status)
				"""
				
				queue.message(delay: 2.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				queue.action(delay: 3.sec, viewTime: 0.sec, action: requestPlayer)
			}
			
		/////////
		// LOSE
		// If they chose the Accomplice, they lose a life.
		case .accomplice:
			
			// NO LIVES
			if handle.kingpinLives <= 0 {
				let resultMsg = """
				The Kingpin looks extremely stupid in front of their fellow crime lords and loses their confidence.
				
				The Kingpin falls and the empire is in ruin.
				"""
				
				queue.message(delay: 2.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				handle.kingpin!.flair.add(withName: "Ran Away", category: KingpinFlair.statusCategory)
				
				queue.action(delay: 3.sec, viewTime: 0.sec) { self.kingpinLoses(pick: kingpinChoice) }
			}
				
				// SAFE
			else {
				
				let status = useLife()
        kingpinChoice.flair.add(KingpinFlair.giftReceived)
				
				let resultMsg = """
				The Kingpin looks pretty stupid in front of their fellow crime lords and offers \(kingpinChoice.name) an extravagant gift to apologise.
				
				The Kingpin remains in control for now and the meeting continues.  \(status)
				"""
				
				queue.message(delay: 2.sec,
											viewTime: 4.sec,
											message: resultMsg,
											chatID: tag.id)
				
				queue.action(delay: 3.sec, viewTime: 0.sec, action: requestPlayer)
			}
			
			
		/////////
		// GET
		// If they chose the Thief, they kill them and retrieve the stolen Opals.
		case .thief:
			
			let resultMsg = """
			\(kingpinChoice.name) starts to sweat, but before they can move a muscle the Kingpin shoots them in place.
			
			\(kingpinChoice.name) collapses.
			"""
			queue.message(delay: 2.sec,
										viewTime: 4.sec,
										message: resultMsg,
										chatID: tag.id)
			
			// Declare them as dead and remove them from the players left.
			kingpinChoice.flair.add(KingpinFlair.dead)
			
			queue.action(delay: 1.sec, viewTime: 0.sec) { self.retrieveOpals(pick: kingpinChoice) }
		
		/////////
		// WHOOPS
		case .kingpin:
      abort(KingpinError.kingpinPickedThemselves)
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
		queue.clear()
		
		// ANNOUNCE OPALS
		
		// Set the messages
		let retrieveMsg1 = """
		The Kingpin approaches \(pick.name)'s lifeless corpse and searches it carefully.
		
		The Kingpin finds \(pick.points[KingpinDefault.opal]!.int) Opals.
		"""
		
		// Schedule them.
		queue.message(delay: 3.sec,
									viewTime: 4.sec,
									message: retrieveMsg1,
									chatID: tag.id)
		
		
		
		// OPAL DECISIONS
		
		// Schedule the Opal retrieval.
		queue.action(delay: 1.sec, viewTime: 0.sec) {
			
			// Retrieve the opals from the dead thief.
			let opalsRetrieved = pick.points[KingpinDefault.opal]!
			
			// Assign the stolen opals back to the vault and see how many we now have.
      self.handle.vault.valuables.add(type: KingpinDefault.opal, amount: opalsRetrieved.value)
			let vaultOpals = self.handle.vault.valuables[KingpinDefault.opal]!
			
			
			// If the Kingpin has all the opals back, end the game immediately.
			if vaultOpals.int == self.handle.startOpals {
				let allThievesDead = """
				The Kingpin has recovered all the Opals, securing the future of the empire.
				"""
				
				self.queue.message(delay: 3.sec,
													 viewTime: 5.sec,
													 message: allThievesDead,
													 chatID: self.tag.id)
				
				self.queue.action(delay: 2.sec, viewTime: 0.sec, action: self.kingpinWins)
			}
			
			// Otherwise continue investigating.
			else if vaultOpals.int < self.handle.startOpals {
				let thievesRemain = """
				The Vault is still missing Opals.
				
				\(pick.name)'s body is dragged out of the room and the meeting continues.
				"""
				
				self.queue.message(delay: 3.sec,
													 viewTime: 5.sec,
													 message: thievesRemain,
													 chatID: self.tag.id)
				
				self.queue.action(delay: 2.sec, viewTime: 0.sec, action: self.requestPlayer)
			}
      
      else {
        self.abort(KingpinError.wrongOpalCount)
      }
		}
	}
  
  
  /////////////////////////////////////////////////////////////////////////////////
  /**
  This route is used to allow the Rogue to make a shot and see if they succeeded or not.
  */
  func rogueShot(_ update: Update) -> Bool {
    
    // VALIDATE TO PLAYERS
    if playersLeft.contains(where: {$0.id == update.from!.tgID}) == false { return false }
    
    let rogues = playersLeft.filter( { $0.role?.definition == .rogue } )
    if rogues.contains(where: {$0.id == update.from!.tgID}) == false { return false }
    
    
    // CLEAR QUEUES AND EVENTS
    baseRoute[["event"]]?.clearAll()
    queue.clear()
    
    if let lastMsg = self.storedMessages[self.rogueKey.data] {
      self.request.sync.editMessage(lastMsg.text!,
                                    messageID: lastMsg.tgID,
                                    inlineMessageID: nil,
                                    markup: nil,
                                    chatID: self.tag.id)
    }
    
    // GET THE SHOOTER
    let shooter = rogues.first(where: {$0.id == update.from!.tgID})!
    
    // ANSWER QUERY
    request.async.answerCallbackQuery(queryID: update.id,
                                      text: "You take the shot...",
                                      showAlert: true)
    
    // CHECK CHOSEN
    if chosenPlayer == nil {
      abort(KingpinError.rogue_noChosenPlayer)
    }
    
    // SHOOT CHOSEN
    chosenPlayer!.flair.add(KingpinFlair.dead)
    
    // ENJOY THE SHOW
    let shootMsg1 = """
    \(shooter.name) immediately pulls out their gun and pulls the trigger several times.
    
    \(chosenPlayer!.name) collapses back into their seat as their blood soaks into the ornate chair.
    """
    
    let shootMsg2 = """
    As \(chosenPlayer!.name)'s body settles, something falls out of their pocket...
    """
    
    queue.message(delay: 3.sec,
                  viewTime: 7.sec,
                  message: shootMsg1,
                  chatID: tag.id)
    
    queue.message(delay: 3.sec,
                  viewTime: 5.sec,
                  message: shootMsg2,
                  chatID: tag.id)
    
    var success = false
    var failMsg1 = ""
    var failMsg2 = ""
    
    switch chosenPlayer!.role!.definition {
      
    case .elite:
      failMsg1 = """
      ... it's a *special Elite Badge!*  (\(chosenPlayer!.name) was the \(chosenPlayer!.role!.name)!)
      """
      
      failMsg2 = """
      \(handle.kingpin!.name) immediately pulls out their own gilded pistol and takes out \(shooter.name) for their incompetence.
      
      The bodies are slowly dragged out of the room and the meeting continues.
      """
      
      
    case .thief:
      let retrievedOpals = chosenPlayer!.points[KingpinDefault.opal]!
      self.handle.vault.valuables.add(type: KingpinDefault.opal, amount: retrievedOpals.value)
      
      failMsg1 = """
      ... it's some *Opals!*  (\(chosenPlayer!.name) was the \(chosenPlayer!.role!.name)!)
      """
      
      failMsg2 = """
			\(handle.kingpin!.name) immediately pulls out their own gilded pistol and takes out \(shooter.name) for their incompetence.
			
			\(handle.kingpin!.name) picks up *\(retrievedOpals.int) Opals.*  Turns out they werent so incompetent after all.
			
			The bodies are slowly dragged out of the room and the meeting continues.
			"""
      
      
    case .spy:
      success = true
      failMsg1 = """
      ... it's a *Foreign Passport*!  (\(chosenPlayer!.name) was the \(chosenPlayer!.role!.name)!)
      """
      
      failMsg2 = """
      \(handle.kingpin!.name) is impressed with \(shooter.name)'s instincts.
      
      Placing their hope in fate, \(handle.kingpin!.name) asks \(shooter.name) to shoot all the Thieves in the room.
      """
      
      
    case .police:
      success = true
      failMsg1 = """
      ... it's a *Police Badge*!  (\(chosenPlayer!.name) was the \(chosenPlayer!.role!.name)!)
      """
      
      failMsg2 = """
      \(handle.kingpin!.name) is impressed with \(shooter.name)'s instincts.
      
      Placing their hope in fate, \(handle.kingpin!.name) asks \(shooter.name) to shoot all the Thieves in the room.
      """
      
      
    case .assistant:
      failMsg1 = """
      ... it's an *Unusual Note!*  (\(chosenPlayer!.name) was the \(chosenPlayer!.role!.name)!)
      """
      
      failMsg2 = """
      \(handle.kingpin!.name) immediately pulls out their own gilded pistol and takes out \(shooter.name) for their incompetence.
      
      The bodies are slowly dragged out of the room and the meeting continues.
      """
      
      
    case .rogue:
      failMsg1 = """
      ... it's an *Identical Pistol!*  (\(chosenPlayer!.name) was the \(chosenPlayer!.role!.name)!)
      """
      
      failMsg2 = """
      \(handle.kingpin!.name) immediately pulls out their own gilded pistol and takes out \(shooter.name) for their incompetence.
      
      The bodies are slowly dragged out of the room and the meeting continues.
      """
      
      
    case .accomplice:
      failMsg1 = """
      ... it's a *Currency Chip!*  (\(chosenPlayer!.name) was the \(chosenPlayer!.role!.name)!)
      """
      
      failMsg2 = """
      \(handle.kingpin!.name) immediately pulls out their own gilded pistol and takes out \(shooter.name) for their incompetence.
      
      The bodies are slowly dragged out of the room and the meeting continues.
      """
      
      
    case .kingpin:
      failMsg1 = """
      ... it's a *EEEEEEEEEEE*  (\(chosenPlayer!.name) was the \(chosenPlayer!.role!.name)!)
      
      Yes, thats right, for some reason \(chosenPlayer!.name) fired on the Kingpin.
      """
      
      failMsg2 = """
      The bullets disappear before they can touch the Kingpin.
      
      Outraged, \(handle.kingpin!.name) immediately pulls out their own gilded pistol and takes out \(shooter.name) for their incompetence.
      
      The body is slowly dragged out of the room and the meeting continues.
      """
      
      
    }
    
    
    queue.message(delay: 3.sec,
                  viewTime: 5.sec,
                  message: failMsg1,
                  chatID: tag.id)
    
    queue.message(delay: 3.sec,
                  viewTime: 7.sec,
                  message: failMsg2,
                  chatID: tag.id)
    
    
    ////////////////
    // OPALS RECOVERED
    
    let opalsRecovered = self.handle.vault.valuables[KingpinDefault.opal]!
    
    if opalsRecovered.value.int == handle.startOpals {
      
      let allThievesDead = """
      Despite the bloody mess, the Kingpin has recovered all the Opals, securing the future of the empire.
      """
      queue.message(delay: 3.sec,
                    viewTime: 6.sec,
                    message: allThievesDead,
                    chatID: tag.id)
      
      self.queue.action(delay: 3.sec, viewTime: 0.sec, action: kingpinWins)
      
      return true
    }
    
    
    ////////////////
    // SUCCESS
      
    if success == true {
      
      var shootMsg1 = ""
      var shootMsg2 = ""
      var shootMsg3 = ""
      
      // KILL THIEVES
      
      let thieves = playersLeft.filter({$0.role?.definition == .thief})
      thieves.forEach {
        $0.flair.add(KingpinFlair.dead)
      }
      
      // CROWN SHOOTER
      
      shooter.flair.add(KingpinFlair.winner)
      
      
      // ASSISTANTS
      
      let assistants = findWinningAssistants() ?? []
      assistants.forEach {
        $0.flair.add(KingpinFlair.winner)
      }
      
      // FINAL MESSAGES
      
      if assistants.count > 0 {
        var assistNoun = "assistant"
        if assistants.count > 1 {
          assistNoun = "assistants"
        }
        
        shootMsg1 = """
        \(shooter.name)'s eyes dart across the room.  Thanks to their \(assistNoun), they know exactly who to take out.
        
        \(shooter.name) takes out \(Player.getListTextSUB(thieves))!
        """
        
        shootMsg2 = """
        Opals dance across the floor as the thieves collapse into their chairs.
        
        Everyone left is in awe of \(shooter.name)'s raw talent.
        """
        
        shootMsg3 = """
        With no equal, \(shooter.name) becomes the new Kingpin.
        
        \(shooter.name) wins!  (\(Player.getListTextSUB(assistants)) helped out!)
        """
      }
      
      else {
        shootMsg1 = """
        \(shooter.name)'s eyes dart across the room, making no hesitation.
        
        \(shooter.name) takes out \(Player.getListTextSUB(thieves))!
        """
        
        shootMsg2 = """
        Opals dance across the floor as the thieves collapse into their chairs.
        
        Everyone left is in awe of \(shooter.name)'s raw talent.
        """
        
        shootMsg3 = """
        With no equal, \(shooter.name) becomes the new Kingpin.
        
        \(shooter.name) wins!
        """
      }
      
      
      queue.message(delay: 3.sec,
                    viewTime: 8.sec,
                    message: shootMsg1,
                    chatID: tag.id)
      
      queue.message(delay: 3.sec,
                    viewTime: 8.sec,
                    message: shootMsg2,
                    chatID: tag.id)
      
      queue.message(delay: 3.sec,
                    viewTime: 7.sec,
                    message: shootMsg3,
                    chatID: tag.id)
      
      self.queue.action(delay: 3.sec, viewTime: 0.sec) {
        self.end(playerTrigger: nil, participants: nil)
      }
      
      return true
    }
      
    ///////////////
    // FAILURE
    
    else {
      shooter.flair.add(KingpinFlair.dead)
      
      queue.action(delay: 2.sec, viewTime: 0.sec, action: requestPlayer)
    }
    
    
    
    return true
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
		
		////////////
		// SPY
		// If the picked player was the spy or police, they immediately win.
		
		if pickRole == .police || pickRole == .spy {
			pick.flair.add(KingpinFlair.winner)
			
			let copsWin = """
			\(pick.name) *wins!*
			"""
			self.queue.message(delay: 2.sec,
												 viewTime: 5.sec,
												 message: copsWin,
												 chatID: self.tag.id)
		}
		
		
		////////////
		// THIEVES
		// If not, find all the thieves and see who got the most Opals, then set them as the winner
			
		else {
			let thieves = handle.players.filter( {
				$0.role!.definition == .thief &&
					$0.flair.find(KingpinFlair.dead, compareContents: false) == false
			} )
			
			var mostOpalsStolen = 0
			thieves.forEach { thief in
				let opals = thief.points[KingpinDefault.opal]?.int ?? 0
				if mostOpalsStolen < opals { mostOpalsStolen = opals }
			}
			
			let bestThieves = thieves.filter( { $0.points[KingpinDefault.opal]?.int ?? 0 == mostOpalsStolen } )
			bestThieves.forEach {
				$0.flair.add(KingpinFlair.winner)
			}
			
			var thiefWin1 = ""
			if bestThieves.count == 1 {
				thiefWin1 = """
				In the collapse of the great crime empire, one thief managed to escape and live a life of luxury.
				
				That thief was...
				"""
			} else {
				thiefWin1 = """
				In the collapse of the great crime empire, a few thieves managed to escape and live a life of luxury.
				
				Those thieves were...
				"""
			}
			
      ////////////
      // ACCOMPLICES
			
			let accomplices = handle.players.filter( {
				$0.role!.definition == .accomplice &&
					$0.flair.find(KingpinFlair.dead, compareContents: false) == false
			} )
      
      accomplices.forEach {
        $0.flair.add(KingpinFlair.winner)
      }
      
			var accompliceText = ""
			if accomplices.count != 0 {
				accompliceText = "Their partners in crime were \(Player.getListTextSUB(accomplices))!"
			}
			
			let thiefWin2 = """
			\(Player.getListTextSUB(bestThieves)) !
			
			\(accompliceText)
			"""
			
			self.queue.message(delay: 2.sec,
												 viewTime: 7.sec,
												 message: thiefWin1,
												 chatID: self.tag.id)
			
			self.queue.message(delay: 2.sec,
												 viewTime: 5.sec,
												 message: thiefWin2,
												 chatID: self.tag.id)
		}
		
		
		////////////
		// ASSISTANTS
		// Find any potential winning assistants and accomplices
		
		let assistants = findWinningAssistants() ?? []
		assistants.forEach {
			$0.flair.add(KingpinFlair.winner)
		}
		
		if assistants.count != 0 {
			
			let assistantWin1 = """
			Someone was secretly helping them!  They were...
			"""
			
			let assistantWin2 = """
			\(Player.getListTextSUB(assistants)) ! ! ! !
			"""
			
			self.queue.message(delay: 2.sec,
												 viewTime: 5.sec,
												 message: assistantWin1,
												 chatID: self.tag.id)
			
			self.queue.message(delay: 2.sec,
												 viewTime: 5.sec,
												 message: assistantWin2,
												 chatID: self.tag.id)
			
		}
		
		
		// Finish the game
		
		self.queue.action(delay: 3.sec, viewTime: 0.sec) {
			self.end(playerTrigger: nil, participants: nil)
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	If the kingpin wins, process celebrations \o/
	*/
	func kingpinWins() {
		
		queue.clear()
		handle.playerRoute.resetRequest()
		
		handle.kingpin!.flair.add(KingpinFlair.winner)
		
		
		// Get a list of the elites and add them to the winning players list.
		
		let elites = handle.players.filter({
			$0.role!.definition == .elite &&
				$0.flair.find(KingpinFlair.dead, compareContents: false) == false
		})
		
		elites.forEach {
			$0.flair.add(KingpinFlair.winner)
		}
		
		
		// Get a list of the assistants that also won.
		
		let assistants = findWinningAssistants() ?? []
    assistants.forEach {
      $0.flair.add(KingpinFlair.winner)
    }
		
		
		// Announce the big win.
		
		var crimeWin1 = """
		While the rest fall silent, the Kingpin and their most loyal followers rejoyce!
		
		The elites were \(Player.getListTextSUB(elites))! ! ! !
		"""
		
		if assistants.count != 0 {
			crimeWin1 += "\n\nThey were assisted by \(Player.getListTextSUB(assistants))! ! ! ! "
		}
		
		self.queue.message(delay: 2.sec,
											 viewTime: 8.sec,
											 message: crimeWin1,
											 chatID: self.tag.id)
		
		
		// Finish the game
		
		self.queue.action(delay: 3.sec, viewTime: 0.sec) {
			self.end(playerTrigger: nil, participants: nil)
		}
		
	}
  
	
	/**
	Try and find some winning assistants.
	*/
	func findWinningAssistants() -> [Player]? {
		
		// If any assistants are in the game, work out if the player below them won.
		let assistants = handle.players.filter( {
			$0.role!.definition == .assistant &&
				$0.flair.find(KingpinFlair.dead, compareContents: false) == false
		} )
		
		var winningAssistants: [Player] = []
		
		// Used to search for Assistants if a tree-like pattern emerges
		func searchCompanion(forAssistant assistant: Player) -> Player {
			let assistIndex = handle.players.index(of: assistant)! + 1
			
			var playerBelow: Player
			if assistIndex == handle.playerCount {
				playerBelow = handle.kingpin!
			} else {
				playerBelow = handle.players[assistIndex]
			}
			
			return playerBelow
		}
		
		
		for assistant in assistants {
			
			print("Calculating assistant wins")
			
			var playerIn = assistant
			var playerFound: Player? = nil
			
			while playerFound == nil || playerFound?.role?.definition == .assistant {
				let result = searchCompanion(forAssistant: playerIn)
				
				if result.role!.definition == .assistant {
					playerIn = result
				} else {
					playerFound = result
					break
				}
			}
			
			if playerFound!.flair.find(KingpinFlair.winner, compareContents: false) == true {
				winningAssistants.append(assistant)
			}
		}
		
		print("Assistants calculated.  \(winningAssistants)")
		
		if winningAssistants.count != 0 {
			return winningAssistants
		} else {
			return nil
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	/**
	Decide what to do now that the Kingpin has pissed off somewhere.
	*/
	func finishEarly() {
		queue.clear()
		
		let nobodyWins1 = """
		The kingpin suddenly clutches their chest before collapsing across the table.
		
		The Kingpin falls and the empire is in ruin.
		"""
		
		let nobodyWins2 = """
		*NOBODY WINS!*

		(ask your butthead friend to be online next time)
		"""
		
		self.queue.message(delay: 2.sec,
											 viewTime: 6.sec,
											 message: nobodyWins1,
											 chatID: self.tag.id)
		
		self.queue.message(delay: 2.sec,
											 viewTime: 6.sec,
											 message: nobodyWins2,
											 chatID: self.tag.id)
		
		self.queue.action(delay: 3.sec, viewTime: 0.sec) {
			self.end(playerTrigger: nil, participants: nil)
		}
		
	}
}
