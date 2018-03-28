//
//  CasedEnum.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation

/**
Defines convenience iteration and string extraction methods for various enumeration types.
*/
public protocol CasedEnum : Hashable, CustomStringConvertible {
	
	var description: String { get }
}

extension CasedEnum {
	static func cases() -> AnySequence<Self> {
		typealias S = Self
		return AnySequence { () -> AnyIterator<S> in
			var raw = 0
			return AnyIterator {
				let current : Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee } }
				guard current.hashValue == raw else { return nil }
				raw += 1
				return current
			}
		}
	}
}
