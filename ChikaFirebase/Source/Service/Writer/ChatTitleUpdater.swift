//
//  ChatTitleUpdater.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ChatTitleUpdater: ChikaCore.ChatTitleUpdater {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func updateTitle(_ title: String, of chatID: ID, completion: @escaping (Result<OK>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        let authUserID = meID
        let updateChildValuesBlock = updateChildValues
        
        getCreator(chatID) { result in
            switch result {
            case .ok(let creator):
                var values = ["chat:participant:title/\(chatID)/\(authUserID)" : title]
                if creator == authUserID {
                    values["chats/\(chatID)/title"] = title
                }
                updateChildValuesBlock(values, completion)
                
            case .err(let error):
                completion(.err(error))
            }
        }
        
        return true
    }
    
    private func updateChildValues(_ values: [String: Any], _ completion: @escaping (Result<OK>) -> Void) {
        database.reference().updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("chat title updated successfully")))
        }
    }
    
    private func getCreator(_ chatID: ID, _ completion: @escaping (Result<String>) -> Void) {
        let chatTitleRef = database.reference().child("chats/\(chatID)/creator")
        
        chatTitleRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let creator = snapshot.value as? String else {
                completion(.ok(""))
                return
            }
            
            completion(.ok(creator))
            
        }) { error in
            completion(.err(error))
        }
    }
    
}
