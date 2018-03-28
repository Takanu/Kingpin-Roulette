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
	
	var name: String
	
	var type: ItemTypeTag
	
	var description: String
	
	var unit: PointUnit
	
	
	
	func getFullName() -> String {
		<#code#>
	}
	
	func getInlineCard() -> InlineResultArticle {
		<#code#>
	}
	
	func clone() -> ItemRepresentible {
		<#code#>
	}
	
	
	
}
