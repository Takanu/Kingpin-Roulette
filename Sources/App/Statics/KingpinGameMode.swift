//
//  KingpinGameMode.swift
//  App
//
//  Created by Ido Constantine on 20/04/2018.
//

import Foundation
import TrashBoat
import Pelican

/// The modes that can be selected after you start a Kingpin game.
enum KingpinGameMode: String, CasedEnum {
  case standard = "Standard"
  case assasin = "Assasin"
  //case chaotic = "Chaotic"
  
  var description: String {
    return rawValue
  }
  
  var inlineKey: MarkupInlineKey {
    return MarkupInlineKey(fromCallbackData: rawValue, text: "\(rawValue) Game")!
  }
}
