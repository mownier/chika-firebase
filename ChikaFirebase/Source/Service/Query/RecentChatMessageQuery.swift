//
//  RecentChatMessageQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class RecentChatMessageQuery: ChikaCore.RecentChatMessageQuery {

    var database: Database
    var messageQuery: ChikaCore.MessageQuery
    
    public init(database: Database, messageQuery: ChikaCore.MessageQuery) {
        self.database = database
        self.messageQuery = messageQuery
    }
    
    public convenience init(database: Database = Database.database()) {
        let messageQuery = MessageQuery(database: database)
        self.init(database: database, messageQuery: messageQuery)
    }
    
    public func getRecentChatMessage(of chatID: ID, completion: @escaping (Result<Message>) -> Void) -> Bool {
        guard !"\(chatID)".isEmpty else {
            completion(.err(Error("empty chat ID")))
            return false
        }
        
        let query = database.reference().child("chat:messages/\(chatID)").queryOrdered(byChild: "created:on").queryLimited(toLast: 1)
        let getMessagesBlock = getMessages
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let info = snapshot.value as? [String : Any], info.keys.count == 1 else {
                completion(.err(Error("chat info contains zero or more than one item")))
                return
            }
            
            let messageIDs = [ID(info.keys.first!)]
            getMessagesBlock(messageIDs, completion)
        }
        
        return true
    }
    
    private func getMessages(_ messageIDs: [ID], _ completion: @escaping (Result<Message>) -> Void) {
        let _ = messageQuery.getMessages(for: messageIDs) { result in
            switch result {
            case .ok(let messages):
                guard messageIDs.count == messages.count,
                    messageIDs == messages.map({ $0.id }) else {
                        completion(.err(Error("could not get recent chat message")))
                        return
                }
                
                completion(.ok(messages[0]))
            
            case .err(let error):
                completion(.err(error))
            }
        }
    }
    
}
