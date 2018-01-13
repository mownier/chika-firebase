//
//  ChatMessageQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseDatabase

public protocol ChatMessageBatchQuery: ChikaCore.ChatMessageQuery {
    
    func withLimit(_ limit: UInt) -> ChatMessageBatchQuery
    func withOffset(_ offset: Double) -> ChatMessageBatchQuery
}

public class ChatMessageQuery: ChatMessageBatchQuery {

    var limit: UInt
    var offset: Double?
    var database: Database
    var messageQuery: ChikaCore.MessageQuery
    
    public init(database: Database, messageQuery: ChikaCore.MessageQuery, limit: UInt) {
        self.limit = limit
        self.offset = 0
        self.database = database
        self.messageQuery = messageQuery
    }
    
    public convenience init(database: Database = Database.database(), limit: UInt = 50) {
        let messageQuery = MessageQuery(database: database)
        self.init(database: database, messageQuery: messageQuery, limit: limit)
    }
    
    public func withLimit(_ aLimit: UInt) -> ChatMessageBatchQuery {
        limit = aLimit
        return self
    }
    
    public func withOffset(_ anOffset: Double) -> ChatMessageBatchQuery {
        offset = anOffset
        return self
    }
    
    public func getMessages(of chatID: ID, completion: @escaping (Result<[Message]>) -> Void) -> Bool {
        let chatID = "\(chatID)"
        
        guard !chatID.isEmpty else {
            completion(.err(Error("chat ID is empty")))
            return false
        }
        
        guard let offset = offset else {
            completion(.ok([]))
            return true
        }
        
        let databaseQuery = getDatabaseQuery(chatID, offset)
        let databaseQueryHandlerBlock = databaseQueryHandler
        
        databaseQuery.observeSingleEvent(of: .value) { snapshot in
            databaseQueryHandlerBlock(snapshot, completion)
        }
        
        return true
    }
    
    private func databaseQueryHandler(_ snapshot: DataSnapshot, _ completion: @escaping (Result<[Message]>) -> Void) {
        guard snapshot.exists(), snapshot.hasChildren() else {
            completion(.err(Error("chat has no messages")))
            return
        }
        
        let messageIDs = getMessageIDs(snapshot)
        getChatMessages(messageIDs, completion)
    }
    
    private func getMessageIDs(_ snapshot: DataSnapshot) -> [ID] {
        var messageIDs: [ID] = []
        
        for child in snapshot.children {
            guard let child = child as? DataSnapshot, !child.key.isEmpty else {
                continue
            }
            
            messageIDs.append(ID(child.key))
        }
        
        messageIDs = Array(Set(messageIDs))
        
        return messageIDs
    }
    
    private func getDatabaseQuery(_ chatID: String, _ offset: Double) -> DatabaseQuery {
        var query = database.reference().child("chat:messages/\(chatID)").queryOrdered(byChild: "created_on")
        
        if offset > 0 {
            query = query.queryEnding(atValue: offset)
        }
        
        if limit > 0 {
            query = query.queryLimited(toLast: limit + 1)
        }
        
        return query
    }
    
    private func getChatMessages(_ messageIDs: [ID], _ completion: @escaping (Result<[Message]>) -> Void) {
        let queryLimit = limit
        
        let _ = messageQuery.getMessages(for: messageIDs) { [weak self] result in
            switch result {
            case .ok(let messages):
                var messages = messages
                
                if messages.count == Int(queryLimit + 1) {
                    let message = messages.removeFirst()
                    self?.offset = message.date.timeIntervalSince1970 * 1000
                    
                } else {
                    self?.offset = nil
                }
                
                completion(.ok(messages))
                
            case .err:
                completion(result)
            }
        }
    }

}
