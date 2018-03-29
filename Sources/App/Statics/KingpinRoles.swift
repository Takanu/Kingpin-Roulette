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
																	 description: "Protect your vault and identify the thieves who have stolen your Opals.  If they weren't a thief, you lose the game.")
	
	static let thief = KingpinRole(role: .thief,
																 description: "Steal some precious Opals and prevent the Kingpin from accusing you.  If he find out, you will not be spared.")
	
	static let henchman = KingpinRole(role: .henchman,
																		description: "A loyal servant of the Kingpin's criminal empire.  Convince the Kingpin you are on their side.")
	
	static let spy = KingpinRole(role: .spy,
															 description: "A spy from a distant nation.  Convince the Kingpin to accuse you so you can extradite them.")
	
	static let police = KingpinRole(role: .police,
																	description: "A local cop deep undercover.  Convince the Kingpin to accuse you so you can arrest them.")
	
	static let assistant = KingpinRole(role: .assistant,
																		 description: "A loyal assistant to the player who in turn order is *ahead of* you.  If they succeed, you do.")
	
	static let bountyHunter = KingpinRole(role: .bountyHunter,
																				description: "Choose someone to kill when the Kingpin chooses them, before they reveal their role.  Take out either a Spy of Police Officer to win.")
}
