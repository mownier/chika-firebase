//
//  OfflinePresenceSwitcher.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class OfflinePresenceSwitcher: ChikaCore.OfflinePresenceSwitcher {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func switchToOffline(withCompletion completion: @escaping (Result<OK>) -> Void) -> Bool {
        let rootRef = database.reference()
        let presenceRef = rootRef.child("person:presence/\(meID)")
        
        let value: [String: Any] = [
            "is:active": false,
            "active:on": ServerValue.timestamp()
        ]
        
        presenceRef.setValue(value) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            rootRef.child(".info/connected").removeAllObservers()
            completion(.ok(OK("switched presence to offline")))
        }
        
        return true
    }
    
}
