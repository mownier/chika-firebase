//
//  ContactRequestQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/27/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ContactRequestQuery: ChikaCore.ContactRequestQuery {

    var meID: String
    var database: Database
    var personQuery: ChikaCore.PersonQuery
    
    public init(meID: String, database: Database, personQuery: ChikaCore.PersonQuery) {
        self.meID = meID
        self.database = database
        self.personQuery = personQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let personQuery = PersonQuery(database: database)
        self.init(meID: meID, database: database, personQuery: personQuery)
    }
    
    public func getContactRequests(withCompletion completion: @escaping (Result<[Contact.Request]>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        let establishedRef = database.reference().child("person:contact:request:established/\(meID)")
        let getPersonsBlock = getPersons
        
        establishedRef.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists(), let snapshotValue = snapshot.value as? [String: [String: Any]] else {
                completion(.ok([]))
                return
            }
            
            getPersonsBlock(snapshotValue, completion)
            
        }) { error in
            completion(.err(error))
        }
        
        return true
    }
    
    private func getPersons(_ snapshotValue: [String: [String: Any]], _ completion: @escaping (Result<[Contact.Request]>) -> Void) {
        let _ = personQuery.getPersons(for: snapshotValue.flatMap({ ID($0.key) })) { result in
            switch result {
            case .ok(let persons):
                guard !persons.isEmpty else {
                    completion(.err(Error("requestors are not existing")))
                    return
                }
                
                var requestInfo: [(Person, [String: Any])] = []
                
                for person in persons {
                    guard let value = snapshotValue["\(person.id)"] else {
                        continue
                    }
                    
                    requestInfo.append((person, value))
                }
                
                guard !requestInfo.isEmpty else {
                    completion(.err(Error("requestors have no contact request details")))
                    return
                }
                
                let requests = requestInfo.map({ item -> Contact.Request in
                    var request = Contact.Request()
                    request.id = ID(item.1["id"] as? String ?? "")
                    request.message = item.1["message"] as? String ?? ""
                    request.requestor = item.0
                    return request
                })
                
                completion(.ok(requests))
            
            case .err(let error):
                completion(.err(error))
            }
        }
    }
    
}
