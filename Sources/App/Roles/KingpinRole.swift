//
//  KingpinRole.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

struct KingpinRole: ItemRepresentible {
	
	/// The specific type definition of the role.
	var definition: KingpinRoleType
	
	/// The name of the role/
	var name: String
	
	/// The item type it belongs to.
	var type: ItemTypeTag = KingpinRoles.type
	
	/// The basic vanilla description for the role, assumes it is being browsed or potentially selected.
	var description: String
	
	/// The informational description that tries to help players understand what their role is.
	var roleGoals: String
	
	init(role: KingpinRoleType, description: String, roleGoals: String) {
		self.definition = role
		self.name = role.rawValue
		self.description = description
		self.roleGoals = roleGoals
	}
	
	func getFullName() -> String {
		return name
	}
	
	/**
  Use this to return a card that should be used when a player that isn't a kingpin tries to view the vault.
  */
	func getInlineCard() -> InlineResultArticle {
		return InlineResultArticle(id: "1",
															 title: "\(name)",
															 description: description,
															 contents: KingpinDefault.fakeInlineContentMsg,
															 markup: nil)
	}
	
	/**
	Return a card that specifically helps the player in the interrogation phase to understand their purpose.
	*/
	func getInformationCard() -> InlineResultArticle {
		return InlineResultArticle(id: "1",
															 title: "You are the \(name)",
			description: roleGoals,
			contents: KingpinDefault.fakeInlineContentMsg,
			markup: nil)
	}
	
	func clone() -> ItemRepresentible {
		return KingpinRole(role: definition, description: description, roleGoals: roleGoals)
	}
	
	
	
}
