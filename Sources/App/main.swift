
import Foundation
import TrashBoat
import Pelican


// Make sure you set up Pelican manually so you can assign it variables.
let pelican = try PelicanBot()

let gameBuilder = SessionBuilder(name: "Game",
                                 spawner: Spawn.perChatID(updateType: [.message, .callbackQuery, .inlineQuery], chatType: [.group, .supergroup]),
                                 idType: .chat,
                                 sessionType: GameSession.self,
                                 setup: nil)

let playerBuilder = SessionBuilder(name: "Player",
                                   spawner: Spawn.perUserID(updateType: [.message, .inlineQuery, .callbackQuery]),
																	 idType: .user,
                                   sessionType: PlayerSession.self,
																	 setup: nil)

pelican.addBuilder(gameBuilder, playerBuilder)

// Set initial Pelican properties
pelican.ignoreInitialUpdates = true
pelican.allowedUpdates = [.message, .callbackQuery, .inlineQuery, .chosenInlineResult]
PLog.displayLogTypes = [.error]

// START IT UP!
try pelican.boot()
