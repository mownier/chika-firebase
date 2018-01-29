//
//  AddedContactListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/28/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class AddedContactListener: ChikaCore.AddedContactListener {

    var meID: String
    var database: Database
    var chatQuery: ChikaCore.ChatQuery
    var personQuery: ChikaCore.PersonQuery
    
    var handle: UInt?
    
    public init(meID: String, database: Database, chatQuery: ChikaCore.ChatQuery, personQuery: ChikaCore.PersonQuery) {
        self.meID = meID
        self.database = database
        self.chatQuery = chatQuery
        self.personQuery = personQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let chatQuery = ChatQuery(meID: meID, database: database)
        let personQuery = PersonQuery(database: database)
        self.init(meID: meID, database: database, chatQuery: chatQuery, personQuery: personQuery)
    }
    
    public func stopListening() -> Bool {
        guard handle != nil else {
            return false
        }
        
        let query = database.reference().child("person:contacts/\(meID)").queryOrdered(byChild: "since").queryLimited(toLast: 1)
        query.removeObserver(withHandle: handle!)
        handle = nil
        
        return true
    }
    
    public func startListening(withCallback callback: @escaping (Result<Contact>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            callback(.err(Error("current user ID is empty")))
            return false
        }
        
        guard handle == nil else {
            callback(.err(Error("already listening on added contact")))
            return false
        }
        
        let query = database.reference().child("person:contacts/\(meID)").queryOrdered(byChild: "since").queryLimited(toLast: 1)
        let getPersonBlock = getPerson
        
        handle = query.observe(.childAdded, with: { snapshot in
            let chatID = ID(snapshot.childSnapshot(forPath: "chat").value as? String ?? "")
            let personID = ID(snapshot.key)
            
            getPersonBlock(personID, chatID, callback)
            
        }) { error in
            callback(.err(error))
        }
        
        return true
    }
    
    private func getPerson(_ personID: ID, _ chatID: ID, _ callback: @escaping (Result<Contact>) -> Void) {
        let getChatBlock = getChat
        
        let _ = personQuery.getPersons(for: [personID]) { result in
            switch result {
            case .ok(let persons):
                guard persons.map({ $0.id }) == [personID], let person = persons.first else {
                    callback(.err(Error("can not get info for the added contact")))
                    return
                }
                
                var contact = Contact()
                contact.person = person
                
                getChatBlock(chatID, contact, callback)
            
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
    private func getChat(_ chatID: ID, _ contact: Contact, _ callback: @escaping (Result<Contact>) -> Void) {
        let _ = chatQuery.getChats(for: [chatID]) { result in
            switch result {
            case .ok(let chats):
                guard chats.map({ $0.id }) == [chatID], let chat = chats.first else {
                    callback(.err(Error("can not get info for the chat assigned to the added contact")))
                    return
                }
                
                var contact = contact
                contact.chat = chat
                callback(.ok(contact))
            
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
}
