//
//  TypingStatusListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/28/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class TypingStatusListener: ChikaCore.TypingStatusListener {

    var meID: String
    var database: Database
    var personQuery: ChikaCore.PersonQuery
    
    var handles: [ID: UInt]
    
    public init(meID: String, database: Database, personQuery: ChikaCore.PersonQuery) {
        self.meID = meID
        self.database = database
        self.personQuery = personQuery
        
        self.handles = [:]
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let personQuery = PersonQuery(database: database)
        self.init(meID: meID, database: database, personQuery: personQuery)
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
        
        let statusRef = database.reference().child("chat:typing:status/\(chatID)")
        statusRef.removeObserver(withHandle: handle)
        handles.removeValue(forKey: chatID)
        
        return true
    }
    
    public func startListening(on chatID: ID, callback: @escaping (Result<TypingStatusListenerObject>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            callback(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !"\(chatID)".isEmpty else {
            callback(.err(Error("chat ID is empty")))
            return false
        }
        
        let authUserID = meID
        let statusRef = database.reference().child("chat:typing:status/\(chatID)")
        let getPersonBlock = getPerson
        
        statusRef.child(authUserID).onDisconnectSetValue(false)
        
        let handle = statusRef.observe(.childChanged, with: { snapshot in
            guard snapshot.exists(), authUserID != snapshot.key else {
                return
            }
            
            let personID = ID(snapshot.key)
            let isTyping = snapshot.value as? Bool ?? false
            let typingStatus = isTyping ? TypingStatus.typing : TypingStatus.notTyping
            
            getPersonBlock(personID, typingStatus, callback)
            
        }) { error in
            callback(.err(error))
        }
        
        handles[chatID] = handle
        
        return true
    }
    
    private func getPerson(_ personID: ID, _ typingStatus: TypingStatus, _ callback: @escaping (Result<TypingStatusListenerObject>) -> Void) {
        let _ = personQuery.getPersons(for: [personID]) { result in
            switch result {
            case .ok(let persons):
                guard persons.map({ $0.id }) == [personID], let person = persons.first else {
                    callback(.err(Error("can not get info of the person")))
                    return
                }
                
                let object = TypingStatusListenerObject(person: person, status: typingStatus)
                callback(.ok(object))
                
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
}
