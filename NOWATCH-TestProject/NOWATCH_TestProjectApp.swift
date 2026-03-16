// Created on 30/05/2024

import SwiftUI

@main
struct NOWATCH_TestProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        let container = persistenceController.container
        let heartRateService = HeartRateService(viewContext: container.viewContext)
        let importService = ImportService(container: container)

        WindowGroup {
            HeartRateView(viewModel: HeartRateViewModel(
                heartRateService: heartRateService,
                importService: importService
            ))
            .environment(\.managedObjectContext, container.viewContext)
        }
    }
}
