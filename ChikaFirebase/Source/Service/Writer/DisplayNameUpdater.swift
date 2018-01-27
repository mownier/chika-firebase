//
//  DisplayDisplayNameUpdater.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/26/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class DisplayNameUpdater: ChikaCore.DisplayNameUpdater {
    
    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func updateDisplayName(withNewValue newDisplayName: String, completion: @escaping (Result<OK>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !newDisplayName.isEmpty else {
            completion(.err(Error("new display name is empty")))
            return false
        }
        
        let values: [String: Any] = [
            "persons/\(meID)/display:name": newDisplayName,
            "person:search/\(meID)/display:name": newDisplayName
        ]
        
        database.reference().updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("updated display name successfully")))
        }
        
        return true
    }
    
}

