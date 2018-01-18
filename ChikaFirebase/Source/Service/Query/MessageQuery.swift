//
//  MessageQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class MessageQuery: ChikaCore.MessageQuery {

    var database: Database
    var personQuery: ChikaCore.PersonQuery
    
    public init(database: Database, personQuery: ChikaCore.PersonQuery) {
        self.database = database
        self.personQuery = personQuery
    }
    
    public convenience init(database: Database = Database.database()) {
        let personQuery = PersonQuery(database: database)
        self.init(database: database, personQuery: personQuery)
    }
    
    public func getMessages(for messageIDs: [ID], completion: @escaping (Result<[Message]>) -> Void) -> Bool {
        let messageIDs = messageIDs.filter({ !"\($0)".isEmpty })
        
        guard !messageIDs.isEmpty else {
            completion(.err(Error("empty messageIDs")))
            return false
        }
        
        var messages = [Message]()
        var messageCounter: UInt = 0 {
            didSet {
                guard messageCounter == messageIDs.count else {
                    return
                }
                
                completion(.ok(messages))
            }
        }
        
        for messageID in messageIDs {
            getMessage(messageID) { message in
                if message != nil {
                    messages.append(message!)
                }
                messageCounter += 1
            }
        }
        
        return true
    }
    
    private func getMessage(_ messageID: ID, _ messageCounterUpdate: @escaping (Message?) -> Void) {
        let messgesRef = database.reference().child("messages/\(messageID)")
        let getPersonsBlock = getPersons
        
        messgesRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let info = snapshot.value as? [String : Any] else {
                messageCounterUpdate(nil)
                return
            }
            
            let author = info["author"] as? String ?? ""
            let content = info["content"] as? String ?? ""
            let createdOn = (info["created:on"] as? Double ?? 0) / 1000
            
            var message = Message()
            message.id = messageID
            message.date = Date(timeIntervalSince1970: createdOn)
            message.content = content
            
            getPersonsBlock([ID(author)], message, messageCounterUpdate)
            
        }) { _ in
            messageCounterUpdate(nil)
        }
    }
    
    private func getPersons(_ personIDs: [ID], _ message: Message, _ messsageCounterUpdate: @escaping (Message?) -> Void) {
        let _ = personQuery.getPersons(for: personIDs) { result in
            switch result {
            case .ok(let persons):
                guard personIDs.count == persons.count,
                    personIDs == persons.map({ $0.id }) else {
                        messsageCounterUpdate(nil)
                        return
                }
                
                var message = message
                message.author = persons[0]
                messsageCounterUpdate(message)
            
            case .err:
                messsageCounterUpdate(nil)
            }
        }
    }
    
}
