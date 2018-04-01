//
//  PlayerSession+InlineQuery.swift
//  App
//
//  Created by Ido Constantine on 29/03/2018.
//

import Foundation
import TrashBoat
import Pelican

extension PlayerSession {
	
	/**
	Used to pick a character for themselves at the beginning.  Only works when they haven't been registered in a game.
	*/
	func inlineCharacter(update: Update) -> Bool {
			
		if proxy == nil {
			
			let availableCharacters = PlayerCharacter.cases().filter({_ in return true})
			var availableCharacterInline: [InlineResultArticle] = []
			
			for (i, char) in availableCharacters.enumerated() {
				let newCard = InlineResultArticle(id: String(i + 1),
																					title: char.rawValue,
																					description: "Choose the \(char.rawValue)",
																					contents: "\(char.rawValue)",
																					markup: nil)
				
				availableCharacterInline.append(newCard)
			}
			
			requests.async.answerInlineQuery(queryID: String(update.id),
																			 results: availableCharacterInline,
																			 nextOffset: nil,
																			 switchPM: nil,
																			 switchPMParam: nil)
			return true
		}
			
		else {
			var articles: [InlineResultArticle] = []
			articles.append(InlineResultArticle(id: "1",
																					title: "You've already chosen a character.",
																					description: "¯\\_(ツ)_/¯",
																					contents: "I like clicking inline buttons that shouldn't be clicked, please pity me.",
																					markup: nil))
			
			requests.async.answerInlineQuery(queryID: String(update.id),
																			 results: articles,
																			 nextOffset: nil,
																			 switchPM: nil,
																			 switchPMParam: nil)
			
			return true
		}
		
	}
	
}
