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
	Used to either display the vault contents when the player is in front of the vault, or the player's current role (if they have one).
	*/
	func inlineVault(update: Update) -> Bool {
		
		// Check to see if we've been given any vault cards.  If we have, display them here.
		if inlineVaultCards.count != 0 {
			
			request.async.answerInlineQuery(queryID: String(update.id),
																			results: inlineVaultCards,
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
			return true
			
		}
		
		// If we're not, see if we have an active role.  If so, tell them they aren't in front of the vault and what their role and purpose is.
		if role != nil {
			
			let card = role!.getInformationCard()
			
			request.async.answerInlineQuery(queryID: String(update.id),
																			results: [card],
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
			return true
		}
		
		// If nothing above, tell them they have to wait to visit the vault.
		else {
			
			let card = InlineResultArticle(id: "1",
																		 title: "You haven't yet visited the Vault.",
																		 description: "You'll have the opportunity to soon...",
																		 contents: "<something secret> (⌐■_■)",
																		 markup: nil)
			
			request.async.answerInlineQuery(queryID: String(update.id),
																			results: [card],
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
		}
		
		return true
	}
	
	/**
	Used to allow the player to see all the potential roles in the game.
	*/
	func inlineRoles(update: Update) -> Bool {
		
		let cards = KingpinRoles.allRoles.map { $0.getInlineCard()  }
    var newCards: [InlineResultArticle] = []
		var i = 1
    
		cards.forEach {
      var newCard = $0
			newCard.tgID = "\(i)"
			i += 1
      newCards.append(newCard)
		}
		
		request.async.answerInlineQuery(queryID: String(update.id),
																		results: newCards,
																		nextOffset: nil,
																		switchPM: nil,
																		switchPMParam: nil)
		
		return true
	}
	
}
