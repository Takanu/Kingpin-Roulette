//
//  KingpinRoles.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

struct KingpinRoles {
	
	static let type = ItemTypeTag(name: "Role",
																symbol: "???",
																pluralisedName: "Roles",
																routeName: "Role",
																description: "")
	
	
	static let kingpin = KingpinRole(role: .kingpin,
																	 description: "Protect your vault and identify the thieves who have stolen your Opals.  If they weren't a thief, you lose the game.",
																	 roleGoals: "Find the thieves and accuse them.  If the person you accuse isn't a thief, you're in trouble.")
	
	static let thief = KingpinRole(role: .thief,
																 description: "Steal some precious Opals and become a thief.",
																 roleGoals: "Play dumb, pretend you're still working for the Kingpin.  DO NOT GET ACCUSED BY THE KINGPIN.")
	
	static let henchman = KingpinRole(role: .henchman,
																		description: "Stay as the Kingpin's loyal henchman.  Convince the Kingpin you are on their side.",
																		roleGoals: "You're still on the Kingpin's side, help them find the thieves.")
	
	static let spy = KingpinRole(role: .spy,
															 description: "Become a spy from a distant nation.  Convince the Kingpin to accuse you.",
															 roleGoals: "Convince the Kingpin to accuse you, so you can extradite them.")
	
	static let police = KingpinRole(role: .police,
																	description: "Become a local cop thats deep undercover, tracking illegal Opal stashes.  Convince the Kingpin to accuse you.",
																	roleGoals: "Convince the Kingpin to accuse you, so you can arrest them.")
	
	static let assistant = KingpinRole(role: .assistant,
																		 description: "Become a loyal assistant to the player who's on Vault watch after you.  If they succeed, you do.",
																		 roleGoals: "Work out the role of the player who went on Vault watch after you, and help them succeed.")
	
	static let rogue = KingpinRole(role: .rogue,
																 description: "Become a rogue with a thirst for the blood of law enforcement. Kill a Spy or Police Officer to win.",
																 roleGoals: "Work out the role of the player who went on Vault watch after you, and help them succeed.")
	
	static let accomplice = KingpinRole(role: .accomplice,
																			description: "Become an accomplice.  You don't want to ACTUALLY steal Opals, but don't mind helping...",
																			roleGoals: "Work out who the thieves are and help them succeed.")
}
