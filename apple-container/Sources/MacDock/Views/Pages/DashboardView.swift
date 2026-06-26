import SwiftUI

struct DashboardView: View {
    @Environment(DaemonService.self) private var daemonService
    @Environment(ContainerService.self) private var containerService
    @Environment(ImageService.self) private var imageService
    @Environment(NetworkService.self) private var networkService
    @Environment(VolumeService.self) private var volumeService
    @Environment(DiskUsageService.self) private var diskUsageService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                header
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(icon: "bolt.fill", label: "Running", value: "\(containerService.runningCount)", color: .blue)
                    StatCard(icon: "shippingbox.fill", label: "Containers", value: "\(containerService.totalCount)", color: .cyan)
                    StatCard(icon: "opticaldisc.fill", label: "Images", value: "\(imageService.totalCount)", color: .green)
                    StatCard(icon: "network", label: "Networks", value: "\(networkService.totalCount)", color: .purple)
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    DiskCard(label: "Images", size: diskUsageService.imagesSize, reclaimable: diskUsageService.imagesReclaimable, color: .green)
                    DiskCard(label: "Containers", size: diskUsageService.containersSize, reclaimable: diskUsageService.containersReclaimable, color: .cyan)
                    DiskCard(label: "Volumes", size: diskUsageService.volumesSize, reclaimable: diskUsageService.volumesReclaimable, color: .purple)
                }
                if daemonService.isRunning { daemonInfo }
                if !containerService.containers.isEmpty { recentContainers }
            }.padding(32)
        }
        .background(MacDockColors.background)
        .task { await refreshAll() }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            Task { await refreshAll() }
        }
    }

    private func refreshAll() async {
        await containerService.refresh()
        await imageService.refresh()
        await networkService.refresh()
        await volumeService.refresh()
        await diskUsageService.refresh()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Dashboard").font(.system(size: 28, weight: .bold)).foregroundStyle(MacDockColors.foreground)
            Text("Apple Container runtime overview").font(.subheadline).foregroundStyle(MacDockColors.mutedForeground)
        }
    }

    private var daemonInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Daemon").font(.headline).foregroundStyle(MacDockColors.foreground).padding(.horizontal, 24).padding(.vertical, 16)
            Divider().background(MacDockColors.border)
            VStack(alignment: .leading, spacing: 12) {
                infoRow("Version", daemonService.version)
                infoRow("Build", daemonService.build)
                infoRow("Data Root", daemonService.dataRoot)
                infoRow("Install Root", daemonService.installRoot)
            }.padding(24)
        }
        .background(MacDockColors.card).clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MacDockColors.border, lineWidth: 1))
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(MacDockColors.mutedForeground).frame(width: 120, alignment: .leading)
            Text(value).font(.system(.body, design: .monospaced)).foregroundStyle(MacDockColors.foreground).lineLimit(1)
            Spacer()
        }
    }

    private var recentContainers: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Containers").font(.headline).foregroundStyle(MacDockColors.foreground).padding(.horizontal, 24).padding(.vertical, 16)
            Divider().background(MacDockColors.border)
            ForEach(containerService.containers.prefix(5), id: \.id) { container in
                ContainerRow(container: container, onInspect: {}, onLogs: {}, onDelete: {})
                if container.id != containerService.containers.prefix(5).last?.id {
                    Divider().background(MacDockColors.border).padding(.leading, 24)
                }
            }
        }
        .background(MacDockColors.card).clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MacDockColors.border, lineWidth: 1))
    }
}

struct DiskCard: View {
    let label: String
    let size: UInt64
    let reclaimable: UInt64
    let color: StatColor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label).font(.subheadline).foregroundStyle(MacDockColors.mutedForeground)
                Spacer()
                Image(systemName: "internaldrive").font(.system(size: 14)).foregroundStyle(color.iconColor)
            }
            Text(size.byteCountFormatted).font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(MacDockColors.foreground)
            if reclaimable > 0 {
                Text("\(reclaimable.byteCountFormatted) reclaimable").font(.caption).foregroundStyle(MacDockColors.mutedForeground)
            }
        }
        .padding(20).background(MacDockColors.card).clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MacDockColors.border, lineWidth: 1))
    }
}
