//
//  PlayerCharacter.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import Pelican

/**
The character types that can be selected, which affect
how the player is visually represented in-game.
*/
enum PlayerCharacter: String, CasedEnum {
	
	case raccoon = "Raccoon"
	case dolphin = "Dolphin"
	case cricket = "Cricket"
	case badger = "Badger"
	case bunny = "Bunny"
	case glove = "Glove"
	case toothpaste = "Toothpaste"
	case spork = "Spork"
	case coconut = "Coconut"
	case oyster = "Oyster"
	case coffee = "Coffee"
	
	var description: String {
		return rawValue
	}
	
	static var inlineKey = MarkupInlineKey(fromInlineQueryCurrent: "Characters", text: "Select Character")
}
