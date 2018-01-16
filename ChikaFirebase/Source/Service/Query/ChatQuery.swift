//
//  ChatQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

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
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let personQuery = PersonQuery(database: database)
        let recentChatMessageQuery = RecentChatMessageQuery(database: database)
        self.init(meID: meID, database: database, personQuery: personQuery, recentChatMessageQuery: recentChatMessageQuery)
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database(), personQuery: ChikaCore.PersonQuery) {
        let recentChatMessageQuery = RecentChatMessageQuery(database: database)
        self.init(meID: meID, database: database, personQuery: personQuery, recentChatMessageQuery: recentChatMessageQuery)
    }
    
    public func getChats(for chatIDs: [ID], completion: @escaping (Result<[Chat]>) -> Void) -> Bool {
        let chatIDs = chatIDs.filter({ !"\($0)".isEmpty })
        
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
            getChat(chatID) { chat in
                if chat != nil {
                    chats.append(chat!)
                }
                
                chatCounter += 1
            }
        }
        
        return true
    }
    
    private func getChat(_ chatID: ID, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        let chatsRef = database.reference().child("chats/\(chatID)")
        let getPersonsBlock = getPersons
        
        chatsRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let info = snapshot.value as? [String : Any],
                let participants = info["participants"] as? [String: Any] else {
                    chatCounterUpdate(nil)
                    return
            }
            
            var chat = Chat()
            chat.id = chatID
            chat.title = info["title"] as? String ?? ""
            chat.creatorID = ID(info["creator"] as? String ?? "")
            
            let personIDs = participants.flatMap({ ID($0.key) })
            getPersonsBlock(personIDs, chat, chatCounterUpdate)
            
        }) { _ in
            chatCounterUpdate(nil)
        }
    }
    
    private func getPersons(_ personIDs: [ID], _ chat: Chat, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        let getRecentChatMessageBlock = getRecentChatMessage
        
        let _ = personQuery.getPersons(for: personIDs) { result in
            switch result {
            case .ok(let persons):
                guard personIDs.count == persons.count,
                    personIDs.sorted(by: { "\($0)" < "\($1)" }) == persons.map({ $0.id }).sorted(by: { "\($0)" < "\($1)" }) else {
                        chatCounterUpdate(nil)
                        return
                }
                
                var chat = chat
                chat.participants = persons
                getRecentChatMessageBlock(chat, chatCounterUpdate)
                
            case .err:
                chatCounterUpdate(nil)
            }
        }
    }
    
    private func getRecentChatMessage(_ chat: Chat, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        let authUserID = meID
        
        let _ = recentChatMessageQuery.getRecentChatMessage(of: chat.id) { result in
            switch result {
            case .ok(let message):
                var chat = chat
                if chat.title.isEmpty {
                    let filtered = chat.participants.filter({ $0.id != ID(authUserID) })
                    let mapped = filtered.map({ $0.displayName })
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
