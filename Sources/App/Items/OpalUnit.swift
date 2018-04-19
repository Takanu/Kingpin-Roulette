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
struct OpalUnit: PointUnit, ItemRepresentible {
  
	// CONFORMANCE
	var name: String = "Opal"
  var pointType: PointType = KingpinDefault.opal
	var itemType: ItemTypeTag = KingpinDefault.opalItemTag
	var description: String = "A rare stone with enormous financial value."
	
	// EXTRAS
	var pluralisedName: String = "Opals"
  var value: PointValue
	
	
  init(value: PointValue) {
    self.value = value
	}
	
	
	func getFullName() -> String {
		return name
	}
	
	func getInlineCard() -> InlineResultArticle {
    
    var tempName = name
    if value.int > 1 {
      tempName = pluralisedName
    }
    
		return InlineResultArticle(id: "1",
															 title: "\(value.int) 💎 \(tempName)",
															 description: description,
															 contents: KingpinDefault.fakeInlineContentMsg,
															 markup: nil)
	}
	
	func clone() -> ItemRepresentible {
    return OpalUnit(value: value)
	}
	
	
	
}
