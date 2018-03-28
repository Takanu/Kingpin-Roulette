//
//  Player+InlineQuery.swift
//  App
//
//  Created by Ido Constantine on 28/03/2018.
//

import Foundation
import TrashBoat
import Pelican

extension Player {
	
	/**
	Used to pick a character for themselves at the beginning.  Only works when they haven't been registered in a game.
	*/
	func inlineCharacter(update: Update) -> Bool {
		
		if status == .idle {
			
			let availableCharacters = PlayerCharacter.cases().filter({ _ in return true })
			var availableCharacterInline: [PlayerCharacter: InlineResultArticle] = [:]
			
			for (i, char) in availableCharacters.enumerated() {
				availableCharacterInline[char] = InlineResultArticle(id: String(i + 1), title: char.rawValue,
																														 description: "Choose the \(char.rawValue)", contents: "\(char.rawValue)", markup: nil)
			}
			
			request.async.answerInlineQuery(queryID: String(update.id),
																			results: availableCharacterInline.values.filter({ _ in return true }),
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
			return true
		}
		
		
	}
	
	/**
	Used to either display the vault contents when the player is in front of the vault, or the player's current role (if they have one).
	*/
	func inlineVault(update: Update) -> Bool {
		
		// Check to see if we're in front of the vault.  If so, return back the things they can select from.
		
		// If we're not, see if we have an active role.  If so, tell them they aren't in front of the vault and what their role and purpose is.
		
		// If nothing above, tell them they have to wait to visit the vault.
		
		
	}
	
}
