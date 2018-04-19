
import Foundation
import TrashBoat
import Pelican


// Make sure you set up Pelican manually so you can assign it variables.
let pelican = try PelicanBot()

// A selective whitelist for the beta.
let chatWhitelist = [-1001073943101, -1001310424502, -1001049787403,     // Properly, Test Group, Saltworld
	-1001085205161, -1001050908134, -1001144343222, -1001126640483]  // Pantsuit Nation, TestONSGroup, TGP Retarded, Spooky House Test Arena


let gameBuilder = SessionBuilder(name: "Game",
                                 spawner: Spawn.perChatID(updateType: [.message, .callbackQuery, .inlineQuery], chatType: [.group, .supergroup]),
                                 idType: .chat,
                                 sessionType: GameSession.self,
                                 setup: nil)

let playerBuilder = SessionBuilder(name: "User",
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
