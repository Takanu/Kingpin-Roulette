//
//  Opal.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

class Opal: PointInstance {
    
	// INHERITANCE
	var value: PointValue
	var type: PointType
	
	var description: String {
		return "???"
	}
    
  var transactions: [PointReceipt] = []
	
	required init(startAmount: PointValue) {
		self.value = startAmount
		self.type = KingpinDefault.opal
	}
    
  func getValue() -> PointUnit {
    return OpalUnit(value: value)
  }
	
	func add(_ change: PointValue) -> PointReceipt? {
		
		let oldValue = value
		let newValue = value.int + change.int
		self.value = .int(max(0, newValue))
		
		return PointReceipt(type: type,
												amountBefore: oldValue,
												amountAfter: self.value,
												change: change)
	}
	
	func add(units: PointUnit...) -> PointReceipt? {
	
		let oldValue = value
		var newValue = value.int
		
		for unit in units {
			newValue += unit.value.int
		}
		
		self.value = .int(max(0, newValue))
		
		return PointReceipt(type: type,
							amountBefore: oldValue,
							amountAfter: self.value,
							change: .int(newValue - oldValue.int))
	}
	
	
}
