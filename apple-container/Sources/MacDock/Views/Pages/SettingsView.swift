import SwiftUI

struct SettingsView: View {
    @Environment(DaemonService.self) private var daemonService
    @Environment(DiskUsageService.self) private var diskUsageService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                header

                section("Daemon") {
                    infoRow("Status", daemonService.isRunning ? "Running" : "Stopped")
                    infoRow("Version", daemonService.version)
                    infoRow("Build", daemonService.build)
                    infoRow("Data Root", daemonService.dataRoot)
                    infoRow("Install Root", daemonService.installRoot)
                }

                section("Disk Usage") {
                    infoRow("Images", (diskUsageService.stats?.images.sizeInBytes ?? 0).byteCountFormatted)
                    infoRow("Containers", (diskUsageService.stats?.containers.sizeInBytes ?? 0).byteCountFormatted)
                    infoRow("Volumes", (diskUsageService.stats?.volumes.sizeInBytes ?? 0).byteCountFormatted)
                }

                section("About") {
                    infoRow("App", "MacDock")
                    infoRow("Runtime", "Apple Container")
                    infoRow("Built with", "SwiftUI")
                }
            }
            .padding(32)
        }
        .background(MacDockColors.background)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings").font(.system(size: 28, weight: .bold)).foregroundStyle(MacDockColors.foreground)
            Text("MacDock configuration and system info").font(.subheadline).foregroundStyle(MacDockColors.mutedForeground)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.headline).foregroundStyle(MacDockColors.foreground).padding(.horizontal, 24).padding(.vertical, 16)
            Divider().background(MacDockColors.border)
            content()
        }
        .background(MacDockColors.card).clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MacDockColors.border, lineWidth: 1))
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        return VStack(spacing: 0) {
            HStack {
                Text(label).font(.subheadline).foregroundStyle(MacDockColors.mutedForeground).frame(width: 120, alignment: .leading)
                Text(value).font(.system(.body, design: .monospaced)).foregroundStyle(MacDockColors.foreground).lineLimit(1).textSelection(.enabled)
                Spacer()
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            Divider().background(MacDockColors.border).padding(.leading, 24)
        }
    }
}
