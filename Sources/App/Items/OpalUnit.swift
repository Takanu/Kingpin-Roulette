//
//  OpalUnit.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

/**
Defines an Opal unit that can be stored as an item as well as a point modifier.
*/
struct OpalUnit: ItemRepresentible {
	
	// CONFORMANCE
	var name: String
	var type: ItemTypeTag
	var description: String
	
	// EXTRAS
	var pluralisedName: String
	var unit: PointUnit
	
	
	init(name: String, pluralisedName: String, type: ItemTypeTag, description: String, unitValue: PointValue) {
		self.name = name
		self.type = type
		self.description = description
		
		self.pluralisedName = pluralisedName
		self.unit = PointUnit(name: name,
													pluralisedName: pluralisedName,
													description: description,
													type: KingpinDefault.opal,
													value: unitValue)
		
	}
	
	
	func getFullName() -> String {
		return name
	}
	
	func getInlineCard() -> InlineResultArticle {
		return InlineResultArticle(id: "1",
															 title: "\(unit.value.intValue) 💎 Opals",
															 description: "A rare stone with enormous financial value.",
															 contents: KingpinDefault.fakeInlineContentMsg,
															 markup: nil)
	}
	
	func clone() -> ItemRepresentible {
		return OpalUnit(name: self.name,
										pluralisedName: self.pluralisedName,
										type: self.type,
										description: self.description,
										unitValue: unit.value)
	}
	
	
	
}
