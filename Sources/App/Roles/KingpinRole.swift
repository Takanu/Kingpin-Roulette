//
//  KingpinRole.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat

struct KingpinRole: ItemRepresentible {
	
	var definition: KingpinRoleType
	
	var name: String
	
	var type: ItemTypeTag = KingpinRoles.type
	
	var description: String
	
	init(role: KingpinRoleType, description: String) {
		self.role = role
		self.name = role.rawValue
		self.description = description
	}
	
	func getFullName() -> String {
		return name
	}
	
	func getInlineCard() -> InlineResultArticle {
		<#code#>
	}
	
	func clone() -> ItemRepresentible {
		<#code#>
	}
	
	
	
}
