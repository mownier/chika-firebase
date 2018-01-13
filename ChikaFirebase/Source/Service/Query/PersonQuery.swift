//
//  PersonQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseAuth
import FirebaseDatabase

public class PersonQuery: ChikaCore.PersonQuery {
    
    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseAuth.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func getPersons(for personIDs: [ID], completion: @escaping (Result<[Person]>) -> Void) -> Bool {
        return true
    }
}
