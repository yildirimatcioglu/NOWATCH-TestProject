// Created on 30/05/2024

import SwiftUI

@main
struct NOWATCH_TestProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        let heartRateService = HeartRateService(viewContext: persistenceController.container.viewContext)
        WindowGroup {
            HeartRateView(viewModel: HeartRateViewModel(
                viewContext: persistenceController.container.viewContext,
                heartRateService: heartRateService,
                importService: ImportService(heartRateService: heartRateService)
            ))
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
