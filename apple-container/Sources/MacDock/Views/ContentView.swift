import SwiftUI

struct ContentView: View {
    @State private var activePage: Page = .dashboard

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(activePage: $activePage)

            Group {
                switch activePage {
                case .dashboard:  DashboardView()
                case .containers: ContainersView()
                case .images:     ImagesView()
                case .volumes:    VolumesView()
                case .networks:   NetworksView()
                case .settings:   SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}
