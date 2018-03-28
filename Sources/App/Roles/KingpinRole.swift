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
	
	init(role: KingpinRoleType, description: String) {
		self.definition = role
		self.name = role.rawValue
		self.description = description
	}
	
	func getFullName() -> String {
		return name
	}
	
	/**
  Use this to return a card that should be used when a player that isn't a kingpin tries to view the vault.
  */
	func getInlineCard() -> InlineResultArticle {
		return InlineResultArticle(id: "1",
															 title: "You are the \(name)",
															 description: description,
															 contents: "I am mysterious.  (⌐■_■)",
															 markup: nil)
	}
	
	func clone() -> ItemRepresentible {
		return KingpinRole(role: definition, description: description)
	}
	
	
	
}
