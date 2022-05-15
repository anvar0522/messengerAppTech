//
//  MessageModel.swift
//  messengerAppTech
//
//  Created by anvar on 06/05/22.
//

import RealmSwift
import UIKit

class MessageList: Object {
    @Persisted var message = ""
    @Persisted var date = Date()
}
