//
//  AddedIntoChatListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/28/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class AddedIntoChatListener: ChikaCore.AddedIntoChatListener {

    var meID: String
    var database: Database
    var chatQuery: ChikaCore.ChatQuery
    
    var handle: UInt?
    
    public init(meID: String, database: Database, chatQuery: ChikaCore.ChatQuery) {
        self.meID = meID
        self.database = database
        self.chatQuery = chatQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let chatQuery = ChatQuery(meID: meID, database: database)
        self.init(meID: meID, database: database, chatQuery: chatQuery)
    }
    
    public func stopListening() -> Bool {
        guard handle != nil else {
            return false
        }
        
        let query = database.reference().child("person:inbox/\(meID)").queryOrdered(byChild: "participant:since").queryLimited(toLast: 1)
        query.removeObserver(withHandle: handle!)
        handle = nil
        
        return true
    }
    
    public func startListening(withCallback callback: @escaping (Result<Chat>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            callback(.err(Error("current user ID is empty")))
            return false
        }
        
        guard handle == nil else {
            callback(.err(Error("already listening when you are added into a chat")))
            return false
        }
        
        let query = database.reference().child("person:inbox/\(meID)").queryOrdered(byChild: "participant:since").queryLimited(toLast: 1)
        let getChatBlock = getChat
        
        handle = query.observe(.childAdded, with: { snapshot in
            let chatID = ID(snapshot.key)
            getChatBlock(chatID, callback)
            
        }) { error in
            callback(.err(error))
        }
        
        return true
    }
    
    private func getChat(_ chatID: ID, _ callback: @escaping (Result<Chat>) -> Void) {
        let _ = chatQuery.getChats(for: [chatID]) { result in
            switch result {
            case .ok(let chats):
                guard chats.map({ $0.id }) == [chatID], let chat = chats.first else {
                    callback(.err(Error("can not info the chat")))
                    return
                }
                
                callback(.ok(chat))
                
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
}
