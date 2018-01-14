//
//  ContactQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ContactQuery: ChikaCore.ContactQuery {

    var meID: String
    var database: Database
    var chatQuery: ChikaCore.ChatQuery
    var personQuery: ChikaCore.PersonQuery
    
    public init(meID: String, database: Database, chatQuery: ChikaCore.ChatQuery, personQuery: ChikaCore.PersonQuery) {
        self.meID = meID
        self.database = database
        self.chatQuery = chatQuery
        self.personQuery = personQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let personQuery = PersonQuery(meID: meID, database: database)
        let chatQuery = ChatQuery(meID: meID, database: database, personQuery: personQuery)
        self.init(meID: meID, database: database, chatQuery: chatQuery, personQuery: personQuery)
    }
    
    public func getContacts(withCompletion completion: @escaping (Result<[Contact]>) -> Void) -> Bool {
        let contactsRef = database.reference().child("person:contacts/\(meID)")
        let contactsReferenceHandlerBlock = contactsReferenceHandler
        contactsRef.observeSingleEvent(of: .value) { snapshot in
            contactsReferenceHandlerBlock(snapshot, completion)
        }
        return true
    }
    
    private func contactsReferenceHandler(_ snapshot: DataSnapshot, _ completion: @escaping (Result<[Contact]>) -> Void) {
        guard snapshot.exists(), snapshot.hasChildren() else {
            completion(.ok([]))
            return
        }
        
        let (personIDs, chatIDs) = getPersonAndChatIDs(snapshot)
        getPersons(personIDs, chatIDs, completion)
    }
    
    private func getPersonAndChatIDs(_ snapshot: DataSnapshot) -> ([ID], [ID: ID]) {
        var personIDs: [ID] = []
        var chatIDs: [ID: ID] = [:]
        
        for child in snapshot.children {
            guard let child = child as? DataSnapshot else {
                continue
            }
            
            guard child.hasChild("chat") else {
                continue
            }
            
            guard let chatKey = child.childSnapshot(forPath: "chat").value as? String, !chatKey.isEmpty else {
                continue
            }
            
            let chatID = ID(chatKey)
            let personID = ID(child.key)
            chatIDs[personID] = chatID
            personIDs.append(personID)
        }
        
        personIDs = Array(Set(personIDs))
        
        return (personIDs, chatIDs)
    }
    
    private func getPersons(_ personIDs: [ID], _ chatIDs: [ID: ID], _ completion: @escaping (Result<[Contact]>) -> Void) {
        let getChatsBlock = getChats
        let _ = personQuery.getPersons(for: personIDs) { result in
            switch result {
            case .ok(let persons):
                getChatsBlock(chatIDs, persons, completion)
            
            case .err(let info):
                completion(.err(info))
            }
        }
    }
    
    private func getChats(_ chatIDs: [ID: ID], _ persons: [Person], _ completion: @escaping (Result<[Contact]>) -> Void) {
        let _ = chatQuery.getChats(for: chatIDs.map({ $0.value })) { result in
            switch result {
            case .ok(let chats):
                let contacts = persons.map({ person -> Contact in
                    var contact = Contact()
                    contact.person = person
                    
                    if let chatID = chatIDs[person.id],
                        let index = chats.index(where: { $0.id == chatID }) {
                        contact.chat = chats[index]
                    }
                    
                    return contact
                    
                }).filter({ !"\($0.chat.id)".isEmpty })
                
                completion(.ok(contacts))
            
            case .err(let info):
                completion(.err(info))
            }
        }
    }
    
}
