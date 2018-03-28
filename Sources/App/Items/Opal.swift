//
//  Opal.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

struct Opal: PointInstance {
	
	// INHERITANCE
	var value: PointValue
	var type: PointType
	
	var description: String {
		return "???"
	}
	
	init(initialAmount: PointValue) {
		self.value = initialAmount
	}
	
	func changeAmount(_ change: PointValue) -> PointReceipt? {
		return
	}
	
	func changeAmount(_ units: PointUnit...) -> PointReceipt? {
		return
	}
	
	
}
