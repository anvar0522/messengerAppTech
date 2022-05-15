//
//  StorageManager.swift
//  messengerAppTech
//
//  Created by anvar on 06/05/22.
//

import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}


    func save(_ messageList: MessageList) {
        try! realm.write {
            realm.add(messageList)
        }
    }
    
    func delete(_ messageList: MessageList) {
        write {
            realm.delete(messageList)
        }
    }
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
