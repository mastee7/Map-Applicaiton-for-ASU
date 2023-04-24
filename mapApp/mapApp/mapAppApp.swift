//
//  mapAppApp.swift
//  mapApp
//
//  Created by Woojeh Chung on 3/19/23.
//

import SwiftUI

@main
struct mapAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
