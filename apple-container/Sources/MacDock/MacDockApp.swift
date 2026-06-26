import SwiftUI
import ContainerAPIClient
import ContainerResource
import Logging

@main
struct MacDockApp: App {
    @State private var daemonService = DaemonService()
    @State private var containerService = ContainerService()
    @State private var imageService = ImageService()
    @State private var volumeService = VolumeService()
    @State private var networkService = NetworkService()
    @State private var diskUsageService = DiskUsageService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(daemonService)
                .environment(containerService)
                .environment(imageService)
                .environment(volumeService)
                .environment(networkService)
                .environment(diskUsageService)
                .preferredColorScheme(.dark)
                .task {
                    await daemonService.initialize()
                    await containerService.refresh()
                    await imageService.refresh()
                    await networkService.refresh()
                    await volumeService.refresh()
                    await diskUsageService.refresh()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1200, height: 800)
    }
}
