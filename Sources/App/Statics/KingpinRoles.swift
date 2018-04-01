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
	
	static let inlineKey = MarkupInlineKey(fromInlineQueryCurrent: "View All Roles", text: "View All Roles")
	
	static let type = ItemTypeTag(name: "Role",
																symbol: "???",
																pluralisedName: "Roles",
																routeName: "Role",
																description: "")
	
	
	static let kingpin = KingpinRole(role: .kingpin,
																	 description: "Protect your vault and identify the thieves who have stolen your Opals.  If they weren't a thief, you lose the game.",
																	 roleGoals: "To win, find the thieves and accuse them.  If the person you accuse isn't a thief, you're in trouble.")
	
	static let thief = KingpinRole(role: .thief,
																 description: "Steal some precious Opals and become a thief.  Avoid being accused by the Kingpin.",
																 roleGoals: "To win, make sure the Kingpin doesn't accuse you.  If the Kingpin loses (without accusing a Spy or Police Officer) and you have the most Opals, you win.")
	
	static let henchman = KingpinRole(role: .henchman,
																		description: "Stay as the Kingpin's loyal henchman.  Convince the Kingpin you are on their side and help them win.",
																		roleGoals: "To win, help the Kingpin find the thieves.")
	
	static let spy = KingpinRole(role: .spy,
															 description: "Become a spy from a distant nation.  Win by convincing the Kingpin to arrest you.",
															 roleGoals: "To win, convince the Kingpin to accuse you so you can extradite them for crimes committed against your nation.")
	
	static let police = KingpinRole(role: .police,
																	description: "Become an undercover Police Officer. Win by convincing the Kingpin to arrest you.",
																	roleGoals: "To win, convince the Kingpin to accuse you so you can arrest them for the many crimes they've committed.")
	
	static let assistant = KingpinRole(role: .assistant,
																		 description: "Become a loyal assistant to the player who's on Vault watch after you.  If they win, you do.",
																		 roleGoals: "To win, work out the role of the player who went on Vault watch after you and help them win.")
	
	static let rogue = KingpinRole(role: .rogue,
																 description: "Become a rogue with a thirst for the blood of law enforcement. Win by killing a Spy or Police Officer as the Kingpin is about to accuse them.",
																 roleGoals: "To win, figure out who the Spy or Police Officer is, then shoot them as the Kingpin is about to accuse them.")
	
	static let accomplice = KingpinRole(role: .accomplice,
																			description: "Become an accomplice.  You don't want to ACTUALLY steal Opals, but don't mind helping...",
																			roleGoals: "To win, work out who the thieves are and help them succeed.")
	
	static let allRoles = [KingpinRoles.kingpin,
												 KingpinRoles.thief,
												 KingpinRoles.henchman,
												 KingpinRoles.spy,
												 KingpinRoles.police,
												 KingpinRoles.assistant,
												 KingpinRoles.accomplice,
												 ]
}
