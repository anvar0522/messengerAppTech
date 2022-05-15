//
//  IncomingMessageTableViewCell.swift
//  messengerAppTech
//
//  Created by anvar on 14/05/22.
//

import UIKit

class IncomingMessageCell: UITableViewCell {
  
    @IBOutlet var bubbleView: UIView!
    @IBOutlet var inMessage: UITextView!
    
    func configure (with message: MessageList) {
        inMessage.text = message.message
}
    
}
