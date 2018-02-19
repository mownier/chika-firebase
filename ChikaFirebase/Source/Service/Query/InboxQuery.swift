//
//  InboxQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class InboxQuery: ChikaCore.InboxQuery {

    var meID: String
    var database: Database
    var chatQuery: ChikaCore.ChatQuery
    
    public init(meID: String, database: Database, chatQuery: ChikaCore.ChatQuery) {
        self.meID = meID
        self.database = database
        self.chatQuery = chatQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let chatQuery = ChatQuery(meID: meID, database: database)
        self.init(meID: meID, database: database, chatQuery: chatQuery)
    }
    
    public func getInbox(withCompletion completion: @escaping (Result<[Chat]>) -> Void) -> Bool {
        let databaseQuery = database.reference().child("person:inbox/\(meID)").queryOrderedByKey()
        
        let getChatsBlock = getChats
        let getChatIDsBlock = getChatIDs
        
        databaseQuery.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists(), snapshot.childrenCount > 0 else {
                completion(.ok([]))
                return
            }
            
            let chatIDs = getChatIDsBlock(snapshot)
            getChatsBlock(chatIDs, completion)
            
        }) { error in
            completion(.err(error))
        }
        
        return true
    }
    
    private func getChatIDs(_ snapshot: DataSnapshot) -> [ID] {
        var chatIDs: [ID] = []
        
        for child in snapshot.children {
            guard let child = child as? DataSnapshot else {
                continue
            }
            
            chatIDs.append(ID(child.key))
        }
        
        return chatIDs
    }
    
    private func getChats(_ chatIDs: [ID], _ completion: @escaping (Result<[Chat]>) -> Void) {
        let _ = chatQuery.getChats(for: chatIDs) { result in
            switch result {
            case .ok(let chats):
                let sorted = chats.sorted(by: {
                    let date1: Date = $0.recent.id.isEmpty ? $0.createdOn : $0.recent.date
                    let date2: Date = $1.recent.id.isEmpty ? $1.createdOn : $1.recent.date
                    
                    return date1 > date2
                })
                completion(.ok(sorted))
                
            case .err(let error):
                completion(.err(error))
            }
        }
    }
    
}
