//
//  ChatViewController.swift
//  messengerAppTech
//
//  Created by anvar on 06/05/22.
//

import UIKit
import RealmSwift
import NotificationCenter

class ChatViewController: UIViewController, UIGestureRecognizerDelegate {
    

    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var messageTF: UITextField!
    @IBOutlet var tableView: UITableView!

    private var messages: Results<MessageList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messages = StorageManager.shared.realm.objects(MessageList.self)
        tableView.dataSource = self
        tableView.delegate = self
        setupLongGestureRecognizerOnCollection()
        scrollToBottom(animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
   
    
    private func setupLongGestureRecognizerOnCollection() {
          let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
              lpgr.minimumPressDuration = 1
              lpgr.delegate = self
             self.tableView.addGestureRecognizer(lpgr)
    }
   
    @objc func keyboardWillHide(notification: NSNotification){
        UIView.animate(withDuration: 0.3, animations: {
            let screenFrame = UIScreen.main.bounds
            var viewFrame = CGRect(x: 0, y: 0, width: screenFrame.size.width, height: screenFrame.size.height)
            viewFrame.origin.y = 0
            self.view.frame = viewFrame
        })
    }
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        let infoValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = infoValue.cgRectValue.size
        UIView.animate(withDuration: 0.3, animations: {
            var viewFrame = self.view.frame
            viewFrame.size.height -= keyboardSize.height
            self.view.frame = viewFrame
        })
        scrollToBottom(animated: false)
    }
    
  
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
         guard gestureReconizer.state != .began else { return }
         let point = gestureReconizer.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: point) {
            print(indexPath.row)
         }
         else {
               print("Could not find index path")
         }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        
        let messageList = MessageList()
        messageList.message = messageTF.text!
        StorageManager.shared.save(messageList)
        tableView.reloadData()
        messageTF.text = ""
        scrollToBottom(animated: true)
    }
    
    private func scrollToBottom(animated: Bool, delay: Double = 0.0) {
        let numberOfRows = tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1
        guard numberOfRows > 0 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
            
            let indexPath = IndexPath(
                row: numberOfRows,
                section: self.tableView.numberOfSections - 1)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
}

extension ChatViewController: UITableViewDelegate,UITableViewDataSource {
   private func configureContextMenu(index: Int) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) { (_) in
                let message = self.messages[index]
                StorageManager.shared.delete(message)
                self.tableView.reloadData()
            }
        return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [delete])
        }
        return context
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomingMessageCell", for: indexPath) as! IncomingMessageCell
        let messageList = messages[indexPath.row]
        cell.configure(with: messageList)
         
        return cell
    }
}

