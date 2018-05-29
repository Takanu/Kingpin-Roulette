//
//  Event_ChooseGameMode.swift
//  App
//
//  Created by Ido Constantine on 20/04/2018.
//

import Foundation
import TrashBoat
import Pelican

class Event_GameMode: KingpinEvent, EventRepresentible {
  
  var eventName: String = "Select Game Mode"
  
  var eventType: EventType = KingpinDefault.eventType
  
  var eventInfo: String = """
  Allows the first player that joined to select a game mode.  This event also populates the Vault and other game characteristics.
  """
  
  /// The inline keys used to request what game mode should be selected.
  var inline: MarkupInline {
    let newInline = MarkupInline()
    KingpinGameMode.cases().forEach { newInline.addRow(sequence: $0.inlineKey) }
    
    return newInline
  }
  
  
  /////////////////////////////////////////////////////////////////////////////////
  /**
   Verify that we have the required game state.
   */
  override func verify(handle: GameHandle) -> Error? {
    
    // Make sure we have the correct number of players
    if handle.players.count < KingpinDefault.minimumPlayers ||
      handle.players.count > KingpinDefault.maximumPlayers {
      return KingpinError.wrongPlayerCount
    }
    
    return nil
  }
  
  
  /////////////////////////////////////////////////////////////////////////////////
  /**
  Start the interrogation proceedings!
  */
  override func execute() {
    
    // TUTORIAL OVERRIDE
    // Let the player decide what mode they want I guess...
//    if handle.useTutorial == true {
//      buildStandardGame()
//      self.end(playerTrigger: nil, participants: nil)
//      return
//    }
    
    
    // MESSAGE SETUP
    
    let msg1 = """
    \(handle.players[0].name), ask your friends what game mode they'd like to play, then select it from the list below.
    
    *Standard Game* - The best option for new players, start out here!
    
    *Rogue Game* - Adds the Rogue role and mixes up role balances for a more challenging game.
    """
    
    let warning = """
    \(handle.players[0].name), you have 20 seconds left to make a decision.
    """
    
    // ROUTE SETUP
    
    let modeRoute = RoutePass(name: "game_mode_select", updateTypes: [.callbackQuery], action: receivePlayerSelection)
    baseRoute[["event"]]?.addRoutes(modeRoute)
    
    
    // MESSAGE QUEUE
    storedMessages["game_mode_select"] = request.sync.sendMessage(msg1,
                                                                  markup: inline,
                                                                  chatID: tag.id)
    
    
    queue.action(delay: 30.sec, viewTime: 0.sec) {
      if let oldMessage = self.storedMessages["game_mode_select"] {
        self.request.sync.editMessage(oldMessage.text!,
                                      messageID: oldMessage.tgID,
                                      inlineMessageID: nil,
                                      markup: nil,
                                      chatID: self.tag.id)
      }
      
      self.storedMessages["game_mode_select"] = self.request.sync.sendMessage(warning,
                                                                    markup: self.inline,
                                                                    chatID: self.tag.id)
    }

    queue.action(delay: 20.sec, viewTime: 0.sec) {
      self.selectMode(nil)
    }
  }
  
  
  /**
  Receive the mode selection from the route.
  */
  func receivePlayerSelection(update: Update) -> Bool {
    
    // VALIDATE TO PLAYER
    if handle.players[0].id != update.from!.tgID { return false }
    
    // VALIDATE TO INLINE KEYS
    let options = inline.getCallbackData()!
    if options.contains(update.content) == false { return false }
    
    // ANSWER QUERY
    request.async.answerCallbackQuery(queryID: update.id,
                                      text: "🙌",
                                      showAlert: true)
    
    // REMOVE INLINE BUTTONS
    if let oldMessage = self.storedMessages["game_mode_select"] {
      let newText = """
      \(oldMessage.text!)
      
      \(handle.players[0].name) selected *\(update.content) Game*.
      """
      self.request.sync.editMessage(newText,
                                    messageID: oldMessage.tgID,
                                    inlineMessageID: nil,
                                    markup: nil,
                                    chatID: self.tag.id)
    }
    
    // BUILD MODE
    selectMode(update.content)
    
    return true
  }
  
  
  /**
  Called from either a timeout condition or the event end-point to make a mode selection, if possible.
  */
  func selectMode(_ mode: String?) {
    queue.clear()
    baseRoute[["event"]]?.clearAll()
    
    if mode == nil {
      let abortMsg = """
      Looks like your friend won't make a selection, so we're just going to stop the game - use /start when your butthead friends stop sleeping.
      """
      
      queue.message(delay: 3.sec,
                    viewTime: 0.sec,
                    message: abortMsg,
                    chatID: tag.id)
      
      queue.action(delay: 3.sec, viewTime: 0.sec) {
        self.abort(KingpinError.noGameModeSelected)
      }
			
			return
    }
    
    
    if mode == KingpinGameMode.standard.rawValue {
      handle.gameMode = .standard
      buildStandardGame()
      end(playerTrigger: nil, participants: nil)
    }
    
    else if mode == KingpinGameMode.rogue.rawValue {
      handle.gameMode = .rogue
      buildRogueGame()
      end(playerTrigger: nil, participants: nil)
    }
    
    else {
      abort(KingpinError.gameModeNotFound)
    }
    
  }

  
  /////////////////////////////////////////////////////////////////////////////////
  /**
  Setup the game to be designed for new or inexperienced playters, or those looking for simpler rules.
  */
  func buildStandardGame() {
    var itemCollection: [ItemRepresentible] = []
    let randomArrestRole = [KingpinRoles.police, KingpinRoles.spy]
    
    
    // RANDOMISE OPALS
    
    func randomiseOpals(_ range: ClosedRange<Int>) -> Int {
      
      var possibilities: [Int] = []
      let start = range.lowerBound
      let diff = range.upperBound - start
      for i in 0...diff {
        possibilities.append(start + i)
      }
      
      return possibilities.getRandom!
    }
    
    
    // SET LIVES
    
    if handle.playerCount >= 11 {
      handle.kingpinLives = 2
      
    } else if handle.playerCount >= 8 || handle.useTutorial == true {
      handle.kingpinLives = 1
    }
    
    
    
    // BUILD VAULT
    
    if handle.playerCount < 6 {
      itemCollection.append(KingpinRoles.rogue)
      itemCollection.append(KingpinRoles.elite)
      itemCollection.append(KingpinRoles.police)
      itemCollection.append(KingpinRoles.spy)
      itemCollection.append(KingpinRoles.thief)
      itemCollection.append(KingpinRoles.assistant)
      
      handle.startOpals = randomiseOpals(12...15)
    }
    
    
    if handle.playerCount == 6 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [randomArrestRole.getRandom!]
      
      handle.startOpals = randomiseOpals(12...15)
    }
    
    
    if handle.playerCount == 7 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [randomArrestRole.getRandom!]
      
      handle.startOpals = randomiseOpals(12...15)
    }
    
    
    if handle.playerCount == 8 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [randomArrestRole.getRandom!]
      
      handle.startOpals = randomiseOpals(12...15)
    }
    
    
    if handle.playerCount == 9 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [randomArrestRole.getRandom!]
      
      handle.startOpals = randomiseOpals(13...17)
    }
    
    
    if handle.playerCount == 10 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [KingpinRoles.police, KingpinRoles.spy]
      
      handle.startOpals = randomiseOpals(13...17)
    }
    
    
    if handle.playerCount == 11 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant, KingpinRoles.assistant]
      itemCollection += [KingpinRoles.police, KingpinRoles.spy]
      
      handle.startOpals = randomiseOpals(15...18)
    }
    
    
    if handle.playerCount == 12 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant, KingpinRoles.assistant]
      itemCollection += [KingpinRoles.police, KingpinRoles.spy]
      
      handle.startOpals = randomiseOpals(15...18)
      
    }
    
    handle.vault.roles.add(itemCollection)
    handle.vault.valuables.add(type: KingpinDefault.opal, amount: .int(handle.startOpals))
  }
  
  /////////////////////////////////////////////////////////////////////////////////
  /**
   Setup the game to be designed for first-time players.
   */
  func buildRogueGame() {
    var itemCollection: [ItemRepresentible] = []
    let randomArrestRole = [KingpinRoles.police, KingpinRoles.spy]
    
    
    // RANDOMISE OPALS
    
    func randomiseOpals(_ range: ClosedRange<Int>) -> Int {
      
      var possibilities: [Int] = []
      let start = range.lowerBound
      let diff = range.upperBound - start
      for i in 0...diff {
        possibilities.append(start + i)
      }
      
      return possibilities.getRandom!
    }
    
    
    // SET LIVES
    
    if handle.playerCount >= 11 {
      handle.kingpinLives = 2
      
    } else if handle.playerCount >= 8 || handle.useTutorial == true {
      handle.kingpinLives = 1
    }
    
    
    
    // BUILD VAULT
    
    if handle.playerCount < 6 {
      itemCollection.append(KingpinRoles.rogue)
      itemCollection.append(KingpinRoles.elite)
      itemCollection.append(KingpinRoles.police)
      itemCollection.append(KingpinRoles.spy)
      itemCollection.append(KingpinRoles.thief)
      itemCollection.append(KingpinRoles.assistant)
      
      handle.startOpals = randomiseOpals(12...15)
    }
    
    
    if handle.playerCount == 6 {
      itemCollection += [KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [randomArrestRole.getRandom!]
      itemCollection += [KingpinRoles.rogue]
      
      handle.startOpals = randomiseOpals(12...15)
    }
    
    
    if handle.playerCount == 7 {
      itemCollection += [KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [randomArrestRole.getRandom!]
      itemCollection += [KingpinRoles.rogue]
      
      handle.startOpals = randomiseOpals(12...15)
    }
    
    
    if handle.playerCount == 8 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [randomArrestRole.getRandom!]
      itemCollection += [KingpinRoles.rogue]
      
      handle.startOpals = randomiseOpals(12...15)
    }
    
    
    if handle.playerCount == 9 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [randomArrestRole.getRandom!]
      itemCollection += [KingpinRoles.rogue]
      
      handle.startOpals = randomiseOpals(13...17)
    }
    
    
    if handle.playerCount == 10 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant]
      itemCollection += [KingpinRoles.police, KingpinRoles.spy]
      itemCollection += [KingpinRoles.rogue]
      
      handle.startOpals = randomiseOpals(13...17)
    }
    
    
    if handle.playerCount == 11 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant, KingpinRoles.assistant]
      itemCollection += [KingpinRoles.police, KingpinRoles.spy]
      itemCollection += [KingpinRoles.rogue]
      
      handle.startOpals = randomiseOpals(15...18)
    }
    
    
    if handle.playerCount == 12 {
      itemCollection += [KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite, KingpinRoles.elite]
      itemCollection += [KingpinRoles.assistant, KingpinRoles.assistant]
      itemCollection += [KingpinRoles.police, KingpinRoles.spy]
      itemCollection += [KingpinRoles.rogue]
      
      handle.startOpals = randomiseOpals(15...18)
      
    }
    
    handle.vault.roles.add(itemCollection)
    handle.vault.valuables.add(type: KingpinDefault.opal, amount: .int(handle.startOpals))
  }
  
  

}
