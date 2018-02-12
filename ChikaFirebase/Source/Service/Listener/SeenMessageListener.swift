//
//  SeenMessageListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 2/10/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class SeenMessageListener: ChikaCore.SeenMessageListener {

    var database: Database
    var personQuery: ChikaCore.PersonQuery
    
    var handles: [ID: UInt]
    
    public init(database: Database, personQuery: ChikaCore.PersonQuery) {
        self.database = database
        self.personQuery = personQuery
        
        self.handles = [:]
    }
    
    public convenience init(database: Database = Database.database()) {
        let personQuery = PersonQuery(database: database)
        self.init(database: database, personQuery: personQuery)
    }
    
    public func stopAll() -> Bool {
        guard !handles.isEmpty else {
            return false
        }
        
        let ok = handles.flatMap({ stopListening(on: $0.key ) }).reduce(true, { $0 && $1 })
        return ok
    }
    
    public func stopListening(on messageID: ID) -> Bool {
        guard let handle = handles[messageID] else {
            return false
        }
        
        let query = database.reference().child("message:read:state/\(messageID)").queryOrdered(byChild: "read:on").queryLimited(toLast: 1)
        query.removeObserver(withHandle: handle)
        handles.removeValue(forKey: messageID)
        
        return true
    }
    
    public func startListening(on messageID: ID, callback: @escaping (Result<SeenMessageListenerObject>) -> Void) -> Bool {
        guard handles[messageID] == nil else {
            callback(.err(Error("already listening on seen message")))
            return false
        }
        
        let query = database.reference().child("message:read:state/\(messageID)").queryOrdered(byChild: "read:on").queryLimited(toLast: 1)
        let getPersonBlock = getPerson
        
        let handle = query.observe(.childAdded, with: { snapshot in
            let personID = ID(snapshot.key)
            getPersonBlock(personID, messageID, callback)
            
        }) { error in
            callback(.err(error))
        }
        
        handles[messageID] = handle
        
        return true
    }
    
    private func getPerson(_ personID: ID, _ messageID: ID, _ callback: @escaping (Result<SeenMessageListenerObject>) -> Void) {
        let _ = personQuery.getPersons(for: [personID]) { result in
            switch result {
            case .ok(let persons):
                guard persons.map({ $0.id }) == [personID], let person = persons.first else {
                    callback(.err(Error("can not get person's info")))
                    return
                }
                
                let object = SeenMessageListenerObject(messageID: messageID, participant: person)
                callback(.ok(object))
            
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
}
