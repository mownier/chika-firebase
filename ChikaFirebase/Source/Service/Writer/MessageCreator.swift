//
//  MessageCreator.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class MessageCreator: ChikaCore.MessageCreator {

    var meID: String
    var database: Database
    var messageQuery: ChikaCore.MessageQuery
    
    public init(meID: String, database: Database, messageQuery: ChikaCore.MessageQuery) {
        self.meID = meID
        self.database = database
        self.messageQuery = messageQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let messageQuery = MessageQuery(database: database)
        self.init(meID: meID, database: database, messageQuery: messageQuery)
    }
    
    public func createMessage(for chatID: ID, content: String, completion: @escaping (Result<Message>) -> Void) -> Bool {
        let rootRef = database.reference()
        let getMessagesBlock = getMessages
        let (messageID, values) = getMessageIDAndValuesForUpdate(content, chatID)
        
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            getMessagesBlock([messageID], completion)
        }
        
        return true
    }
    
    private func getMessages(_ messageIDs: [ID], _ completion: @escaping (Result<Message>) -> Void) {
        let _ = messageQuery.getMessages(for: messageIDs) { result in
            switch result {
            case .ok(let messages):
                guard messageIDs == messages.map({ $0.id })else {
                    completion(.err(Error("succesfully written a message but failed to fetch the new message")))
                    return
                }
                
            case .err(let error):
                completion(.err(error))
            }
        }
    }
    
    private func getMessageIDAndValuesForUpdate(_ content: String, _ chatID: ID) -> (ID, [String: Any]) {
        let timestamp = ServerValue.timestamp()
        let messageKey = database.reference().child("messages").childByAutoId().key
        
        let message: [String: Any] = [
            "id": messageKey,
            "chat": "\(chatID)",
            "author": meID,
            "content": content.trimmingCharacters(in: .newlines),
            "created:on": timestamp
        ]
        
        let values: [String: Any] = [
            "messages/\(messageKey)": message,
            "chats/\(chatID)/updated:on": timestamp,
            "chat:messages/\(chatID)/\(messageKey)/created:on": timestamp
        ]
        
        return (ID(messageKey), values)
    }
    
}
