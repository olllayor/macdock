import SwiftUI

enum Page: String, CaseIterable, Identifiable {
    case dashboard, containers, images, volumes, networks, settings

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .containers: return "Containers"
        case .images: return "Images"
        case .volumes: return "Volumes"
        case .networks: return "Networks"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .containers: return "shippingbox.fill"
        case .images: return "opticaldisc.fill"
        case .volumes: return "internaldrive.fill"
        case .networks: return "network"
        case .settings: return "gearshape.fill"
        }
    }
}

struct SidebarView: View {
    @Binding var activePage: Page
    @Environment(DaemonService.self) private var daemonService

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [MacDockColors.chartBlue, MacDockColors.chartCyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 32, height: 32)
                    .overlay(Image(systemName: "shippingbox.fill").font(.system(size: 16)).foregroundStyle(.white))
                Text("MacDock").font(.system(size: 18, weight: .bold)).foregroundStyle(MacDockColors.sidebarForeground)
                Spacer()
                Circle().fill(daemonService.isRunning ? MacDockColors.chartGreen : MacDockColors.destructive).frame(width: 8, height: 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(24)
            Divider().background(MacDockColors.sidebarBorder)

            VStack(spacing: 4) {
                ForEach(Page.allCases) { page in
                    Button { activePage = page } label: {
                        HStack(spacing: 12) {
                            Image(systemName: page.icon).font(.system(size: 16)).frame(width: 20)
                            Text(page.label).font(.system(.body, weight: .medium))
                            Spacer()
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .foregroundStyle(activePage == page ? MacDockColors.sidebarPrimaryForeground : MacDockColors.sidebarForeground)
                        .background(activePage == page ? MacDockColors.sidebarPrimary : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }.buttonStyle(.plain)
                }
            }.padding(16)

            Spacer()
            Divider().background(MacDockColors.sidebarBorder)

            HStack(spacing: 8) {
                Circle().fill(daemonService.isRunning ? MacDockColors.chartGreen : MacDockColors.destructive).frame(width: 6, height: 6)
                Text(daemonService.isRunning ? "Daemon running" : "Daemon stopped").font(.caption).foregroundStyle(MacDockColors.mutedForeground)
                Spacer()
            }.padding(.horizontal, 20).padding(.vertical, 16)
        }
        .frame(width: 260).background(MacDockColors.sidebar)
        .overlay(Rectangle().fill(MacDockColors.sidebarBorder).frame(width: 1), alignment: .trailing)
    }
}
