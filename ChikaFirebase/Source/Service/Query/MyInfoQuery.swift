//
//  MyInfoQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/15/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class MyInfoQuery: ChikaCore.MyInfoQuery {

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
    
    public func getMyInfo(withCompletion completion: @escaping (Result<Person>) -> Void) -> Bool {
        let personIDs = [ID(meID)]
        let getEmailBlock = getEmail
        
        let ok = personQuery.getPersons(for: personIDs) { result in
            switch result {
            case .ok(let persons):
                guard personIDs.count == persons.count,
                    personIDs == persons.map({ $0.id }) else {
                        completion(.err(Error("could not get info")))
                        return
                }
                
                getEmailBlock(persons[0], completion)
                
            case .err(let error):
                completion(.err(error))
            }
        }
        return ok
    }
    
    private func getEmail(_ person: Person, _ completion: @escaping (Result<Person>) -> Void) {
        let emailRef = database.reference().child("person:email/\(person.id)")
        
        emailRef.observeSingleEvent(of: .value, with: { snapshot in
            var person = person
            
            if snapshot.exists(), let email = snapshot.value as? String {
                person.email = email
            }
            
            completion(.ok(person))
            
        }) { error in
            completion(.err(error))
        }
    }
    
}
