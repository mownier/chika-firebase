//
//  ChatTitleUpdateListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/28/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ChatTitleUpdateListener: ChikaCore.ChatTitleUpdateListener {

    var handles: [ID: UInt]
    var database: Database
    
    public init(database: Database = Database.database()) {
        self.handles = [:]
        self.database = database
    }
    
    public func stopAll() -> Bool {
        guard !handles.isEmpty else {
            return false
        }
        
        let ok = handles.flatMap({ stopListening(on: $0.key ) }).reduce(true, { $0 && $1 })
        return ok
    }
    
    public func stopListening(on chatID: ID) -> Bool {
        guard let handle = handles[chatID] else {
            return false
        }
        
        let titleRef = database.reference().child("chats/\(chatID)/title")
        titleRef.removeObserver(withHandle: handle)
        handles.removeValue(forKey: chatID)
        
        return true
    }
    
    public func startListening(on chatID: ID, callback: @escaping (Result<ChatTitleUpdateListenerObject>) -> Void) -> Bool {
        guard !"\(chatID)".isEmpty else {
            callback(.err(Error("chat ID is empty")))
            return false
        }
        
        guard handles[chatID] == nil else {
            callback(.err(Error("already listening when chat's title will be updated")))
            return false
        }
        
        let titleRef = database.reference().child("chats/\(chatID)/title")
        let handle = titleRef.observe(.value, with: { snapshot in
            guard snapshot.exists(), let title = snapshot.value as? String else {
                callback(.err(Error("can not get updated chat title")))
                return
            }
            
            let object = ChatTitleUpdateListenerObject(chatID: chatID, title: title)
            callback(.ok(object))
            
        }) { error in
            callback(.err(error))
        }
        
        handles[chatID] = handle
        
        return true
    }
}
