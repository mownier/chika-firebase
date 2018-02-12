//
//  MessageSeenInfoQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 2/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class MessageSeenInfoQuery: ChikaCore.MessageSeenInfoQuery {

    public var limit: UInt
    public var database: Database
    public var personQuery: ChikaCore.PersonQuery
    
    public init(database: Database, limit: UInt, personQuery: ChikaCore.PersonQuery) {
        self.limit = limit
        self.database = database
        self.personQuery = personQuery
    }
    
    public convenience init(database: Database = Database.database(), limit: UInt = 10) {
        let personQuery = PersonQuery(database: database)
        self.init(database: database, limit: limit, personQuery: personQuery)
    }
    
    @discardableResult
    public func getMessageSeenInfo(withID messageID: ID, completion: @escaping (Result<Message.SeenInfo>) -> Void) -> Bool {
        guard !"\(messageID)".isEmpty else {
            completion(.err(Error("message ID is empty")))
            return false
        }
        
        let rootRef = database.reference()
        let query = rootRef.child("message:read:state/\(messageID)").queryOrdered(byChild: "read:on").queryLimited(toFirst: limit)
        let getPersonsBlock = getPersons
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                completion(.err(Error("message read state not found")))
                return
            }
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(.err(Error("snapshot value is not a dictionary")))
                return
            }
            
            var seenInfo = Message.SeenInfo()
            seenInfo.messageID = messageID
            
            let personIDs: [ID] = value.flatMap({ ID($0.key) })
            getPersonsBlock(personIDs, seenInfo, completion)
            
        }) { error in
            completion(.err(error))
        }
        
        return true
    }
    
    private func getPersons(_ personIDs: [ID], _ seenInfo: Message.SeenInfo, _ completion: @escaping (Result<Message.SeenInfo>) -> Void) {
        let getReadCountBlock = getReadCount
        let _ = personQuery.getPersons(for: personIDs) { result in
            switch result {
            case .ok(let persons):
                guard persons.map({ $0.id }).sorted(by: { "\($0)" < "\($1)" }) == personIDs.sorted(by: { "\($0)" < "\($1)" }) else {
                    completion(.err(Error("can not get informartion of the participants")))
                    return
                }
                
                var info = seenInfo
                info.participants = persons
                getReadCountBlock(info, completion)
            
            case .err(let error):
                completion(.err(error))
            }
        }
    }
    
    private func getReadCount(_ seenInfo: Message.SeenInfo, _ completion: @escaping (Result<Message.SeenInfo>) -> Void) {
        let readCountRef = database.reference().child("message:read:count/\(seenInfo.messageID)")
        let getRemainingBlock = getRemaining
        
        readCountRef.observeSingleEvent(of: .value, with: { snapshot in
            var info = seenInfo
            info.count = snapshot.value as? UInt ?? 0
            
            getRemainingBlock(info, completion)
            
        }) { error in
            completion(.err(error))
        }
    }
    
    private func getRemaining(_ seenInfo: Message.SeenInfo, _ completion: @escaping (Result<Message.SeenInfo>) -> Void) {
        let rootRef = database.reference()
        let messageChatRef = rootRef.child("messages/\(seenInfo.messageID)/chat")
        
        messageChatRef.observeSingleEvent(of: .value, with: { snapshot in
            let chatKey = snapshot.value as? String ?? ""
            let participantCountRef = rootRef.child("chat:participant:count/\(chatKey)")
            
            participantCountRef.observeSingleEvent(of: .value, with: { snapshot in
                let participantCount = snapshot.value as? UInt ?? 0
                let remaining = participantCount - seenInfo.count
                
                var info = seenInfo
                info.remaining = remaining
                
                completion(.ok(info))
                
            }) { error in
                completion(.err(error))
            }
            
        }) { error in
            completion(.err(error))
        }
    }
    
}
