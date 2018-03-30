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
	
	/// The minimum number of players required to start the game.
	static var minimumPlayers = 2
	
	/// The maximum number of players that can play the game.
	static var maximumPlayers = 15
	
	/// The starting length of time available to choose a character.
	static var charSelectTime = 35.sec
	
	/// The time left on the character select timer in order to trigger a reminder.
	static var charSelectWarningTime = 25.sec
	
	/// The time available for deciding if players want to be the Kingpin.
	static var kingpinSelectTime = 20.sec
	
	/// The time alloted for interrogations
	static var kingpinInterrogationTime = 300.sec
	
	/// The time where the first warning will be triggered.
	static var kingpinInterrogationFirstWarning = 60.sec
	
	/// The time where the last warning will be triggered.
	static var kingpinInterrogationLastWarning = 30.sec
	
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
															instance: Opal.self)
	
	static var fakeInlineContentMsg = "*something secret* (⌐■_■)"
}
