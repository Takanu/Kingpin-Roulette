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
	
	required init(initialAmount: PointValue) {
		self.value = initialAmount
		self.type = KingpinDefault.opal
	}
	
	func changeAmount(_ change: PointValue) -> PointReceipt? {
		
		let oldValue = value
		let newValue = value.intValue + change.intValue
		self.value = .int(max(0, newValue))
		
		return PointReceipt(type: type,
												amountBefore: oldValue,
												amountAfter: self.value,
												change: change)
	}
	
	func changeAmount(_ units: PointUnit...) -> PointReceipt? {
	
		let oldValue = value
		var newValue = value.intValue
		
		for unit in units {
			newValue += unit.value.intValue
		}
		
		self.value = .int(max(0, newValue))
		
		return PointReceipt(type: type,
												amountBefore: oldValue,
												amountAfter: self.value,
												change: .int(newValue - oldValue.intValue))
	}
	
	
}
