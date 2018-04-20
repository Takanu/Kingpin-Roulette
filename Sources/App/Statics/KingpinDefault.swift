//
//  KingpinDefault.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

/**
Contains statics on game pacing, text prompts, item types and more.
*/

struct KingpinDefault {
	
	/// The version number of the App
	static var versionNumber = "2"
	
  /// The type for defining a KingpinEvent
  static var eventType: EventType = EventType(name: "Kingpin Event",
                                              symbol: "👑",
                                              pluralisedName: "Kingpin Event",
                                              description: "oh hey, it's an event.")
	
	// GAME START
	/// The minimum number of players required to start the game.
	static var minimumPlayers = 6
	
	/// The maximum number of players that can play the game.
	static var maximumPlayers = 12
	
	/// The starting length of time available to choose a character.
	static var charSelectTime = 150.sec
	
	/// The time left on the character select timer in order to trigger a reminder.
	static var charSelectWarningTime = 25.sec
	
	/// The amount a time extension is worth.
	static var timeExtensionLength = 30.sec
	
	/// The number of times you can extend the time
	static var maxTimeExtensions = 4
	
  
	// KINGPIN SELECTION
	/// The time available for deciding if players want to be the Kingpin.
	static var kingpinSelectTime = 25.sec
	
	
	// VAULT VISIT
	/// The maximum number of opals anyone can steal when visiting the vault.
	static var maxOpalTheft = 15
	
	
	// INTERROGATION TIME
	/// The time alloted for interrogations
	static var kingpinInterrogationTime = 300.sec
	
	/// The time where the first warning will be triggered.
	static var kingpinInterrogationFirstWarning = 180.sec
	
	/// The time where the second warning will be triggered.
	static var kingpinInterrogationSecondWarning = 60.sec
	
	/// The time where the last warning will be triggered.
	static var kingpinInterrogationLastWarning = 30.sec
	
	
	// ITEMS
	/// The valuable that can be stolen as an item type.
	static var opalItemTag = ItemTypeTag(name: "Opal",
																		symbol: "💎",
																		pluralisedName: "Opals",
																		routeName: "Opal",
																		description: "The valuable that can be stolen and that the Kingpin needs to retrieve.")
	
	/// The valuable that can be stolen and that the Kingpin needs to retrieve.
	static var opal = PointType(name: "Opal",
                                pluralisedName: "Opals",
                                symbol: "💎",
                                instance: Opal.self,
                                unit: OpalUnit.self)
	
	static var fakeInlineContentMsg = "*something secret* (⌐■_■)"
}
