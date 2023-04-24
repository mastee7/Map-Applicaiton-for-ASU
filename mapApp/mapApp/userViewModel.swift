//
//  userViewModel.swift
//  mapApp
//
//  Created by Woojeh Chung on 4/21/23.
//

import Foundation
import CoreData

public class userViewModel: ObservableObject
{
    @Published var email: String = ""
    @Published var pNum: String = ""
    @Published var usrId: String = ""
    @Published var usrPw: String = ""
    @Published var navigateToContentView: Bool = false
    
    private (set) var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
    }
    
    // A function that adds a user to coredata
    func add() {
        do{
            let user = AppUser(context: context)
            user.email = email
            user.pNum = pNum
            user.usrId = usrId
            user.usrPw = usrPw
            try context.save()
            navigateToContentView = true
        } catch {
            print(error)
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // A function that is going to fetch the user input and check if it exists in coredata
    func fetchUser(withId id: String, password: String) -> AppUser? {
        let fetchRequest: NSFetchRequest<AppUser> = AppUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "usrId == %@ AND usrPw == %@", id, password)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching user: \(error)")
        }
        return nil
    }

    
}
