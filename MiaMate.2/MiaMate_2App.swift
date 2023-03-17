//
//  MiaMate_2App.swift
//  MiaMate.2
//
//  Created by Arianne Xaing on 14/03/2023.
//

import SwiftUI

@main
struct MiaMate_2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
