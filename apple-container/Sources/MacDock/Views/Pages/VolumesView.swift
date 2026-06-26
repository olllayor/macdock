import SwiftUI
import ContainerResource

struct VolumesView: View {
    @Environment(VolumeService.self) private var volumeService
    @SwiftUI.State private var showCreateSheet = false
    @SwiftUI.State private var selectedVolume: VolumeConfiguration?
    @SwiftUI.State private var showDetail = false
    @SwiftUI.State private var volumeToDelete: VolumeConfiguration?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { header; content }
        }
        .background(MacDockColors.background)
        .task { await volumeService.refresh() }
        .sheet(isPresented: $showCreateSheet) { CreateVolumeSheet() }
        .sheet(isPresented: $showDetail) {
            if let v = selectedVolume { VolumeDetailSheet(volume: v) }
        }
        .alert("Delete Volume", isPresented: Binding(
            get: { volumeToDelete != nil },
            set: { if !$0 { volumeToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { volumeToDelete = nil }
            Button("Delete", role: .destructive) {
                if let v = volumeToDelete { Task { try? await volumeService.delete(name: v.name) } }
                volumeToDelete = nil
            }
        } message: { Text("Delete volume '\(volumeToDelete?.name ?? "")'? Data will be permanently lost.") }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Volumes").font(.system(size: 28, weight: .bold)).foregroundStyle(MacDockColors.foreground)
                Text("Persistent storage for containers").font(.subheadline).foregroundStyle(MacDockColors.mutedForeground)
            }
            Spacer()
            Button { showCreateSheet = true } label: {
                Label("New Volume", systemImage: "plus")
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
                Text("Name").headerCell().frame(width: 160, alignment: .leading)
                Text("Driver").headerCell().frame(width: 80, alignment: .leading)
                Text("Size").headerCell().frame(width: 80, alignment: .leading)
                Spacer()
                Text("Actions").headerCell().frame(width: 60, alignment: .leading)
            }.padding(.horizontal, 24).padding(.vertical, 14).background(MacDockColors.muted.opacity(0.3))
            Divider().background(MacDockColors.border)

            if volumeService.volumes.isEmpty {
                emptyState
            } else {
                ForEach(volumeService.volumes, id: \.name) { volume in
                    HStack(spacing: 16) {
                        Text(volume.name).font(.system(.body, weight: .medium)).foregroundStyle(MacDockColors.foreground).frame(width: 160, alignment: .leading)
                        Text(volume.driver).font(.system(.body)).foregroundStyle(MacDockColors.mutedForeground).frame(width: 80, alignment: .leading)
                        Text(volume.sizeInBytes?.byteCountFormatted ?? "—").font(.system(.body, design: .monospaced)).foregroundStyle(MacDockColors.mutedForeground).frame(width: 80, alignment: .leading)
                        Spacer()
                        ActionButton(icon: "info.circle", color: MacDockColors.chartBlue) {
                            selectedVolume = volume; showDetail = true
                        }
                        ActionButton(icon: "trash.fill", color: MacDockColors.destructive) {
                            volumeToDelete = volume
                        }
                    }
                    .padding(.horizontal, 24).padding(.vertical, 14)
                    .contextMenu {
                        Button("Inspect") { selectedVolume = volume; showDetail = true }
                        Divider()
                        Button("Delete", role: .destructive) { volumeToDelete = volume }
                    }
                    if volume.name != volumeService.volumes.last?.name {
                        Divider().background(MacDockColors.border).padding(.leading, 24)
                    }
                }
            }
        }
        .padding(.horizontal, 32).background(MacDockColors.card).clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MacDockColors.border, lineWidth: 1))
        .padding(.horizontal, 32)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "internaldrive").font(.system(size: 48)).foregroundStyle(MacDockColors.muted)
            Text("No volumes").font(.headline).foregroundStyle(MacDockColors.mutedForeground)
            Text("Click \"New Volume\" to create one").font(.caption).foregroundStyle(MacDockColors.muted)
        }.frame(maxWidth: .infinity).padding(.vertical, 60)
    }
}
