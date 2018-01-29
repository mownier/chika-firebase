//
//  ReceivedContactRequestListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/28/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ReceivedContactRequestListener: ChikaCore.ReceivedContactRequestListener {

    var meID: String
    var database: Database
    var personQuery: ChikaCore.PersonQuery
    
    var handle: UInt?
    
    public init(meID: String, database: Database, personQuery: ChikaCore.PersonQuery) {
        self.meID = meID
        self.database = database
        self.personQuery = personQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let personQuery = PersonQuery(database: database)
        self.init(meID: meID, database: database, personQuery: personQuery)
    }
    
    public func stopListening() -> Bool {
        guard handle != nil else {
            return false
        }
        
        let query = database.reference().child("person:contact:request:established/\(meID)").queryOrdered(byChild: "created:on").queryLimited(toLast: 1)
        query.removeObserver(withHandle: handle!)
        handle = nil
        
        return true
    }
    
    public func startListening(withCallback callback: @escaping (Result<Contact.Request>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            callback(.err(Error("current user ID is empty")))
            return false
        }
        
        guard handle == nil else {
            callback(.err(Error("already listening on contact requests that will be received")))
            return false
        }
        
        let query = database.reference().child("person:contact:request:established/\(meID)").queryOrdered(byChild: "created:on").queryLimited(toLast: 1)
        let getPersonBlock = getPerson
        
        handle = query.observe(.childAdded, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            
            let personID = ID(snapshot.key)
            
            var request = Contact.Request()
            request.id = ID(value["id"] as? String ?? "")
            request.message = value["message"] as? String ?? ""
            
            getPersonBlock(personID, request, callback)
            
        }) { error in
            callback(.err(error))
        }
        
        return true
    }
    
    private func getPerson(_ personID: ID, _ request: Contact.Request, _ callback: @escaping (Result<Contact.Request>) -> Void) {
        let _ = personQuery.getPersons(for: [personID]) { result in
            switch result {
            case .ok(let persons):
                guard persons.map({ $0.id }) == [personID], let person = persons.first else {
                    callback(.err(Error("can not info of the requestor")))
                    return
                }
                
                var request = request
                request.requestor = person
                
                callback(.ok(request))
            
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
}
