//
//  RecentChatMessageListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/28/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class RecentChatMessageListener: ChikaCore.RecentChatMessageListener {

    var meID: String
    var database: Database
    var messageQuery: ChikaCore.MessageQuery
    
    var handles: [ID: UInt]
    
    public init(meID: String, database: Database, messageQuery: ChikaCore.MessageQuery) {
        self.meID = meID
        self.database = database
        self.messageQuery = messageQuery
        
        self.handles = [:]
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let messageQuery = MessageQuery(database: database)
        self.init(meID: meID, database: database, messageQuery: messageQuery)
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
        
        let query = database.reference().child("chat:messages/\(chatID)").queryOrdered(byChild: "created:on").queryLimited(toLast: 1)
        query.removeObserver(withHandle: handle)
        handles.removeValue(forKey: chatID)
        
        return true
    }
    
    public func startListening(on chatID: ID, callback: @escaping (Result<RecentChatMessageListenerObject>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            callback(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !"\(chatID)".isEmpty else {
            callback(.err(Error("chat ID is empty")))
            return false
        }
        
        guard handles[chatID] == nil else {
            callback(.err(Error("already listening on chat's recent message")))
            return false
        }
        
        let query = database.reference().child("chat:messages/\(chatID)").queryOrdered(byChild: "created:on").queryLimited(toLast: 1)
        let getMessageBlock = getMessage
        
        let handle = query.observe(.childAdded, with: { snapshot in
            let messageID = ID(snapshot.key)
            getMessageBlock(messageID, chatID, callback)
            
        }) { error in
            callback(.err(error))
        }
        
        handles[chatID] = handle
        
        return true
    }
    
    private func getMessage(_ messageID: ID, _ chatID: ID, _ callback: @escaping (Result<RecentChatMessageListenerObject>) -> Void) {
        let _ = messageQuery.getMessages(for: [messageID]) { result in
            switch result {
            case .ok(let messages):
                guard messages.map({ $0.id }) == [messageID], let message = messages.first else {
                    callback(.err(Error("can not get info of the recent chat message")))
                    return
                }
                
                let object = RecentChatMessageListenerObject(chatID: chatID, message: message)
                callback(.ok(object))
            
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
}
