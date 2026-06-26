import SwiftUI
import ContainerResource

struct ContainersView: View {
    @Environment(ContainerService.self) private var containerService
    @SwiftUI.State private var showCreateSheet = false
    @SwiftUI.State private var selectedContainer: ContainerSnapshot?
    @SwiftUI.State private var showDetail = false
    @SwiftUI.State private var showLogs = false
    @SwiftUI.State private var logsContainerId: String?
    @SwiftUI.State private var containerToDelete: ContainerSnapshot?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                content
            }
        }
        .background(MacDockColors.background)
        .task { await containerService.refresh() }
        .sheet(isPresented: $showCreateSheet) { CreateContainerSheet() }
        .sheet(isPresented: $showDetail) {
            if let c = selectedContainer { ContainerDetailSheet(container: c) }
        }
        .sheet(isPresented: $showLogs) {
            if let id = logsContainerId { LogsSheet(containerId: id) }
        }
        .alert("Delete Container", isPresented: Binding(
            get: { containerToDelete != nil },
            set: { if !$0 { containerToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { containerToDelete = nil }
            Button("Delete", role: .destructive) {
                if let id = containerToDelete?.id { Task { try? await containerService.delete(id: id) } }
                containerToDelete = nil
            }
        } message: { Text("Are you sure? This cannot be undone.") }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Containers").font(.system(size: 28, weight: .bold)).foregroundStyle(MacDockColors.foreground)
                Text("Manage containers via Apple Container runtime").font(.subheadline).foregroundStyle(MacDockColors.mutedForeground)
            }
            Spacer()
            Button { showCreateSheet = true } label: {
                Label("New Container", systemImage: "plus")
                    .font(.system(.body, weight: .medium))
                    .foregroundStyle(MacDockColors.accentForeground)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(MacDockColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }.buttonStyle(.plain)
        }.padding(32)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                Text("Name").headerCell().frame(width: 140, alignment: .leading)
                Text("Image").headerCell().frame(width: 140, alignment: .leading)
                Text("Status").headerCell().frame(width: 80, alignment: .leading)
                Spacer()
                Text("CPU").headerCell().frame(width: 60, alignment: .leading)
                Text("Memory").headerCell().frame(width: 80, alignment: .leading)
                Text("Actions").headerCell().frame(width: 100, alignment: .leading)
            }
            .padding(.horizontal, 24).padding(.vertical, 14)
            .background(MacDockColors.muted.opacity(0.3))
            Divider().background(MacDockColors.border)

            if containerService.containers.isEmpty {
                emptyState
            } else {
                ForEach(containerService.containers, id: \.id) { container in
                    ContainerRow(container: container, onInspect: { selectedContainer = container; showDetail = true }, onLogs: { logsContainerId = container.id; showLogs = true }, onDelete: { containerToDelete = container })
                    if container.id != containerService.containers.last?.id {
                        Divider().background(MacDockColors.border).padding(.leading, 24)
                    }
                }
            }
        }
        .padding(.horizontal, 32).background(MacDockColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MacDockColors.border, lineWidth: 1))
        .padding(.horizontal, 32)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox").font(.system(size: 48)).foregroundStyle(MacDockColors.muted)
            Text("No containers").font(.headline).foregroundStyle(MacDockColors.mutedForeground)
            Text("Click \"New Container\" to create one").font(.caption).foregroundStyle(MacDockColors.muted)
        }.frame(maxWidth: .infinity).padding(.vertical, 60)
    }
}

struct ContainerRow: View {
    let container: ContainerSnapshot
    var onInspect: () -> Void
    var onLogs: () -> Void
    var onDelete: () -> Void
    @Environment(ContainerService.self) private var containerService

    var body: some View {
        HStack(spacing: 16) {
            Text(container.configuration.id).font(.system(.body, weight: .medium)).foregroundStyle(MacDockColors.foreground).frame(width: 140, alignment: .leading).lineLimit(1)
            Text(container.configuration.image.reference).font(.system(.body)).foregroundStyle(MacDockColors.mutedForeground).frame(width: 140, alignment: .leading).lineLimit(1)
            Text(container.status.rawValue.capitalized).font(.caption.weight(.medium)).foregroundStyle(statusColor).padding(.horizontal, 10).padding(.vertical, 4).background(statusColor.opacity(0.1)).clipShape(Capsule())
            Spacer()
            Text("\(container.configuration.resources.cpus)").font(.system(.body, design: .monospaced)).foregroundStyle(MacDockColors.mutedForeground).frame(width: 60, alignment: .leading)
            Text(container.configuration.resources.memoryInBytes.byteCountFormatted).font(.system(.body, design: .monospaced)).foregroundStyle(MacDockColors.mutedForeground).frame(width: 80, alignment: .leading)
            HStack(spacing: 4) {
                ActionButton(icon: "info.circle", color: MacDockColors.chartBlue) { onInspect() }
                ActionButton(icon: "text.alignleft", color: MacDockColors.chartCyan) { onLogs() }
                if container.status == .running {
                    ActionButton(icon: "stop.fill", color: MacDockColors.destructive) { Task { try? await containerService.stop(id: container.id) } }
                } else {
                    ActionButton(icon: "play.fill", color: MacDockColors.chartGreen) { Task { try? await containerService.start(id: container.id) } }
                }
                ActionButton(icon: "trash.fill", color: MacDockColors.destructive) { onDelete() }
            }
        }
        .padding(.horizontal, 24).padding(.vertical, 14)
        .contextMenu {
            Button("Inspect") { onInspect() }
            Button("Logs") { onLogs() }
            Divider()
            if container.status == .running {
                Button("Stop") { Task { try? await containerService.stop(id: container.id) } }
            } else {
                Button("Start") { Task { try? await containerService.start(id: container.id) } }
            }
            Divider()
            Button("Delete", role: .destructive) { onDelete() }
        }
    }

    private var statusColor: Color {
        container.status == .running ? MacDockColors.chartGreen : MacDockColors.muted
    }
}
