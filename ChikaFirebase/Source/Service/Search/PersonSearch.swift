//
//  PersonSearch.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/29/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import TNExtensions
import FirebaseCommunity

public class PersonSearch: ChikaCore.PersonSearch {
    
    var meID: String
    var database: Database
    var chatQuery: ChikaCore.ChatQuery
    var personQuery: ChikaCore.PersonQuery
    var emailValidator: EmailValidatable
    
    public init(meID: String, database: Database, chatQuery: ChikaCore.ChatQuery, personQuery: ChikaCore.PersonQuery, emailValidator: EmailValidatable) {
        self.meID = meID
        self.database = database
        self.chatQuery = chatQuery
        self.personQuery = personQuery
        self.emailValidator = emailValidator
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let chatQuery = ChatQuery(meID: meID, database: database)
        let personQuery = PersonQuery(database: database)
        let emailValidator = EmailValidator()
        self.init(meID: meID, database: database, chatQuery: chatQuery, personQuery: personQuery, emailValidator: emailValidator)
    }
    
    public func searchPersons(withKeyword keyword: String, completion: @escaping (Result<[Person.SearchObject]>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !keyword.isEmpty else {
            completion(.ok([]))
            return false
        }
        
        if emailValidator.isValidEmail(Email(keyword)) {
            let words = keyword.lowercased().split(separator: "@")
            if !words.isEmpty, let searchText = words.first {
                searchByChild("email", String(searchText), completion)
                return true
            }
        }
        
        var searchResults: [Person.SearchObject] = []
        var searchCounter: UInt = 0 {
            didSet {
                guard searchCounter == 2 else {
                    return
                }
                
                completion(.ok(Array(Set(searchResults))))
            }
        }
        
        searchByChild("name", keyword) { result in
            switch result {
            case .ok(let objects):
                searchResults.append(contentsOf: objects)
            
            case .err:
                break
            }
            searchCounter += 1
        }
        
        searchByChild("display:name", keyword) { result in
            switch result {
            case .ok(let objects):
                searchResults.append(contentsOf: objects)
                
            case .err:
                break
            }
            searchCounter += 1
        }
        
        return true
    }
    
    private func searchByChild(_ childKey: String, _ searchText: String, _ completion: @escaping (Result<[Person.SearchObject]>) -> Void) {
        let handleSearchSnapshotBlock = handleSearchSnapshot
        
        let query = database.reference().child("person:search").queryOrdered(byChild: childKey).queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText+"\u{f8ff}")
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            print(searchText)
            print(childKey)
            guard snapshot.exists(), snapshot.hasChildren() else {
                completion(.ok([]))
                return
            }
            
            handleSearchSnapshotBlock(snapshot, completion)
            
        }) { error in
            completion(.err(error))
        }
    }
    
    private func handleSearchSnapshot(_ snapshot: DataSnapshot, _ completion: @escaping (Result<[Person.SearchObject]>) -> Void) {
        let rootRef = database.reference()
        let authUserID = meID
        let childrenCount = snapshot.childrenCount
        
        var chatInfo: [ID: Chat] = [:]
        var contactInfo: [ID: Bool] = [:]
        var pendingInfo: [ID: Bool] = [:]
        var requestedInfo: [ID: Bool] = [:]
        
        var personIDs: [ID] = []
        var personIDCounter: UInt = 0 {
            didSet {
                guard personIDCounter == childrenCount else {
                    return
                }
                
                guard !personIDs.isEmpty else {
                    completion(.ok([]))
                    return
                }
                
                getPersons(personIDs, contactInfo, requestedInfo, pendingInfo, chatInfo, completion)
            }
        }
        
        for child in snapshot.children {
            guard let child = child as? DataSnapshot, !child.key.isEmpty, child.key != meID else {
                personIDCounter += 1
                continue
            }
            
            let personID = ID(child.key)
            getContactInfo(personID, { item in
                if item != nil  {
                    if item!.1 != nil {
                        chatInfo[item!.0] = item!.1!
                    }
                    contactInfo[personID] = item!.2
                    requestedInfo[personID] = item!.3
                    pendingInfo[personID] = item!.4
                    personIDs.append(item!.0)
                }
                
                personIDCounter += 1
            })
        }
    }
    
    private func getContactInfo(_ personID: ID, _ personIDCounterUpdate: @escaping ((ID, Chat?, Bool, Bool, Bool)?) -> Void) {
        let rootRef = database.reference()
        let personContactsRef = rootRef.child("person:contacts/\(meID)/\(personID)")
        
        let authUserID = meID
        let getChatBlock = getChat
        
        personContactsRef.observeSingleEvent(of: .value, with: { snapshot in
            let isContact = snapshot.exists()
            let chatID = ID(snapshot.childSnapshot(forPath: "chat").value as? String ?? "")
            let establishedRef = rootRef.child("person:contact:request:established/\(authUserID)/\(personID)")
            
            establishedRef.observeSingleEvent(of: .value, with: { snapshot in
                var isRequested = false
                var isPending = false
                
                if snapshot.exists() {
                    isPending = snapshot.hasChild("requestee") && snapshot.childSnapshot(forPath: "requestee").value as? String == authUserID
                    isRequested = snapshot.hasChild("requestor") && snapshot.childSnapshot(forPath: "requestor").value as? String == authUserID
                }
                
                getChatBlock(chatID, personID, isContact, isRequested, isPending, personIDCounterUpdate)
                
            }) { _ in
                personIDCounterUpdate((personID, nil, isContact, false, false))
            }
            
        }) { _ in
            personIDCounterUpdate((personID, nil, false, false, false))
        }
    }
    
    private func getChat(_ chatID: ID, _ personID: ID, _ isContact: Bool, _ isRequested: Bool, _ isPending: Bool, _ personIDCounterUpdate: @escaping ((ID, Chat?, Bool, Bool, Bool)?) -> Void) {
        let _ = chatQuery.getChats(for: [chatID]) { result in
            switch result {
            case .ok(let chats):
                var chat: Chat?
                if chats.map({ $0.id }) == [chatID] {
                    chat = chats.first
                }
                
                personIDCounterUpdate((personID, chat, isContact, isRequested, isPending))
            
            case .err:
                personIDCounterUpdate((personID, nil, isContact, isRequested, isPending))
            }
        }
    }
    
    private func getPersons(_ personIDs: [ID], _ contactInfo: [ID: Bool], _ requestedInfo: [ID: Bool], _ pendingInfo: [ID: Bool], _ chatInfo: [ID: Chat], _ completion: @escaping (Result<[Person.SearchObject]>) -> Void) {
        let _ = personQuery.getPersons(for: personIDs) { result in
            switch result {
            case .ok(let persons):
                guard personIDs.sorted(by: { "\($0)" < "\($1)" }) == persons.map({ $0.id }).sorted(by: { "\($0)" < "\($1)" }) else {
                    completion(.ok([]))
                    return
                }
                
                let persons = persons.filter({
                    guard let isContact = contactInfo[$0.id],
                        requestedInfo[$0.id] != nil,
                        pendingInfo[$0.id] != nil else {
                            return false
                    }
                    
                    if (isContact && chatInfo[$0.id] == nil) ||
                        (!isContact && chatInfo[$0.id] != nil){
                        return false
                    }
                    
                    return true
                })
                
                guard !persons.isEmpty else {
                    completion(.ok([]))
                    return
                }
                
                let objects: [Person.SearchObject] = persons.map({ person -> Person.SearchObject in
                    var object = Person.SearchObject()
                    object.person = person
                    object.isContact = contactInfo[person.id] ?? false
                    object.isRequested = requestedInfo[person.id] ?? false
                    object.isPending = pendingInfo[person.id] ?? false
                    if let chat = chatInfo[person.id] {
                        object.chat = chat
                    }
                    return object
                })
                
                completion(.ok(objects))
                
            case .err(let error):
                completion(.err(error))
            }
        }
    }
    
}
