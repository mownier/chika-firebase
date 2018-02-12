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
        let getMessageBlock = getMessage
        let (messageID, values) = getMessageIDAndValuesForUpdate(content, chatID)
        
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            getMessageBlock(messageID, completion)
        }
        
        return true
    }
    
    private func getMessage(_ messageID: ID, _ completion: @escaping (Result<Message>) -> Void) {
        let _ = messageQuery.getMessages(for: [messageID]) { result in
            switch result {
            case .ok(let messages):
                guard messages.map({ $0.id }) == [messageID], let message = messages.first else {
                    completion(.err(Error("succesfully written a message but failed to fetch the new message")))
                    return
                }
                
                completion(.ok(message))
                
            case .err(let error):
                completion(.err(error))
            }
        }
    }
    
    private func getMessageIDAndValuesForUpdate(_ content: String, _ chatID: ID) -> (ID, [String: Any]) {
        let timestamp = ServerValue.timestamp()
        let messageKey = database.reference().child("messages").childByAutoId().key
        
        let values: [String: Any] = [
            "chats/\(chatID)/updated:on": timestamp,
            
            "messages/\(messageKey)/id": messageKey,
            "messages/\(messageKey)/chat": "\(chatID)",
            "messages/\(messageKey)/author": meID,
            "messages/\(messageKey)/content": content.trimmingCharacters(in: .whitespacesAndNewlines),
            "messages/\(messageKey)/created:on": timestamp,
            
            "chat:messages/\(chatID)/\(messageKey)/created:on": timestamp
        ]
        
        return (ID(messageKey), values)
    }
    
}
