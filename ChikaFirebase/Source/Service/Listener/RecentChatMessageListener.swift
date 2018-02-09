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
    var chatQuery: ChikaCore.ChatQuery
    
    var handles: [ID: UInt]
    
    public init(meID: String, database: Database, chatQuery: ChikaCore.ChatQuery) {
        self.meID = meID
        self.database = database
        self.chatQuery = chatQuery
        
        self.handles = [:]
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let chatQuery = ChatQuery(meID: meID, database: database)
        self.init(meID: meID, database: database, chatQuery: chatQuery)
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
    
    public func startListening(on chatID: ID, callback: @escaping (Result<Chat>) -> Void) -> Bool {
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
        let getChatBlock = getChat
        
        let handle = query.observe(.childAdded, with: { _ in
            getChatBlock(chatID, callback)
            
        }) { error in
            callback(.err(error))
        }
        
        handles[chatID] = handle
        
        return true
    }
    
    func getChat(_ chatID: ID, _ callback: @escaping (Result<Chat>) -> Void) {
        let _ = chatQuery.getChats(for: [chatID]) { result in
            switch result {
            case .ok(let chats):
                guard chats.map({ $0.id }) == [chatID], let chat = chats.first else {
                    callback(.err(Error("could not get chat info")))
                    return
                }
                
                callback(.ok(chat))
                
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
}
