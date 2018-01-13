//
//  ChatQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseAuth
import FirebaseDatabase

public class ChatQuery: ChikaCore.ChatQuery {

    var meID: String
    var database: Database
    var personQuery: ChikaCore.PersonQuery
    var recentChatMessageQuery: ChikaCore.RecentChatMessageQuery
    
    public init(meID: String, database: Database, personQuery: ChikaCore.PersonQuery, recentChatMessageQuery: ChikaCore.RecentChatMessageQuery) {
        self.meID = meID
        self.database = database
        self.personQuery = personQuery
        self.recentChatMessageQuery = recentChatMessageQuery
    }
    
    public convenience init(meID: String = FirebaseAuth.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let personQuery = PersonQuery(meID: meID, database: database)
        let recentChatMessageQuery = RecentChatMessageQuery(database: database)
        self.init(meID: meID, database: database, personQuery: personQuery, recentChatMessageQuery: recentChatMessageQuery)
    }
    
    public convenience init(meID: String = FirebaseAuth.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database(), personQuery: ChikaCore.PersonQuery) {
        let recentChatMessageQuery = RecentChatMessageQuery(database: database)
        self.init(meID: meID, database: database, personQuery: personQuery, recentChatMessageQuery: recentChatMessageQuery)
    }
    
    public func getChats(for chatIDs: [ID], completion: @escaping (Result<[Chat]>) -> Void) -> Bool {
        let chatIDs = chatIDs.map({ "\($0)" })
        
        guard !chatIDs.isEmpty else {
            completion(.err(Error("empty chatIDs")))
            return false
        }
        
        var chats: [Chat] = []
        var chatCounter: UInt = 0 {
            didSet {
                guard chatCounter == chatIDs.count else {
                    return
                }
                
                completion(.ok(chats))
            }
        }
        
        for chatID in chatIDs {
            guard !chatID.isEmpty else {
                chatCounter += 1
                continue
            }
            
            getChat(chatID) { chat in
                if chat != nil {
                    chats.append(chat!)
                }
                
                chatCounter += 1
            }
        }
        
        return true
    }
    
    private func getChat(_ chatID: String, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        let chatsRef = database.reference().child("chats/\(chatID)")
        let getPersonsBlock = getPersons
        
        chatsRef.observeSingleEvent(of: .value) { snapshot in
            guard let info = snapshot.value as? [String : Any],
                let participants = info["participants"] as? [String: Any] else {
                    chatCounterUpdate(nil)
                    return
            }
            
            var chat = Chat()
            chat.id = ID(chatID)
            chat.title = info["title"] as? String ?? ""
            chat.creatorID = ID(info["creator"] as? String ?? "")
            
            let personIDs = participants.flatMap({ ID($0.key) })
            
            getPersonsBlock(personIDs, chat, chatCounterUpdate)
        }
    }
    
    private func getPersons(_ personIDs: [ID], _ chat: Chat, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        var chat = chat
        let getRecentChatMessageBlock = getRecentChatMessage
        
        let _ = personQuery.getPersons(for: personIDs) { result in
            switch result {
            case .ok(let persons):
                guard personIDs.count == persons.count,
                    personIDs == persons.map({ $0.id }) else {
                        chatCounterUpdate(nil)
                        return
                }
                
                chat.participants = persons
                getRecentChatMessageBlock(chat, chatCounterUpdate)
                
            case .err:
                chatCounterUpdate(nil)
            }
        }
    }
    
    private func getRecentChatMessage(_ chat: Chat, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        var chat = chat
        let authUserID = meID
        
        let _ = recentChatMessageQuery.getRecentChatMessage(of: chat.id) { result in
            switch result {
            case .ok(let message):
                if chat.title.isEmpty {
                    let filtered = chat.participants.filter({ $0.id != ID(authUserID) })
                    let mapped = filtered.map({ $0.displayName.isEmpty ? $0.name : $0.displayName })
                    let title = mapped.joined(separator: ", ")
                    chat.title = title
                }
                chat.recent = message
                chatCounterUpdate(chat)
                
            case .err:
                chatCounterUpdate(nil)
            }
        }
    }

}