import SwiftUI
import ContainerResource

struct NetworksView: View {
    @Environment(NetworkService.self) private var networkService
    @SwiftUI.State private var showCreateSheet = false
    @SwiftUI.State private var selectedNetwork: NetworkResource?
    @SwiftUI.State private var showDetail = false
    @SwiftUI.State private var networkToDelete: NetworkResource?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { header; content }
        }
        .background(MacDockColors.background)
        .task { await networkService.refresh() }
        .sheet(isPresented: $showCreateSheet) { CreateNetworkSheet() }
        .sheet(isPresented: $showDetail) {
            if let n = selectedNetwork { NetworkDetailSheet(network: n) }
        }
        .alert("Delete Network", isPresented: Binding(
            get: { networkToDelete != nil },
            set: { if !$0 { networkToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { networkToDelete = nil }
            Button("Delete", role: .destructive) {
                if let n = networkToDelete { Task { try? await networkService.delete(id: n.id) } }
                networkToDelete = nil
            }
        } message: { Text("Delete network '\(networkToDelete?.name ?? "")'? Containers using this network will be disconnected.") }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Networks").font(.system(size: 28, weight: .bold)).foregroundStyle(MacDockColors.foreground)
                Text("Virtual networks for container communication").font(.subheadline).foregroundStyle(MacDockColors.mutedForeground)
            }
            Spacer()
            Button { showCreateSheet = true } label: {
                Label("New Network", systemImage: "plus")
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
                Text("Plugin").headerCell().frame(width: 120, alignment: .leading)
                Text("Subnet").headerCell()
                Spacer()
                Text("Actions").headerCell().frame(width: 60, alignment: .leading)
            }.padding(.horizontal, 24).padding(.vertical, 14).background(MacDockColors.muted.opacity(0.3))
            Divider().background(MacDockColors.border)

            if networkService.networks.isEmpty {
                emptyState
            } else {
                ForEach(networkService.networks) { network in
                    HStack(spacing: 16) {
                        Text(network.name).font(.system(.body, weight: .medium)).foregroundStyle(MacDockColors.foreground).frame(width: 160, alignment: .leading)
                        Text(network.configuration.plugin).font(.system(.body)).foregroundStyle(MacDockColors.mutedForeground).frame(width: 120, alignment: .leading)
                        Text(network.status.ipv4Subnet.description).font(.system(.caption, design: .monospaced)).foregroundStyle(MacDockColors.mutedForeground)
                        Spacer()
                        HStack(spacing: 4) {
                            ActionButton(icon: "info.circle", color: MacDockColors.chartBlue) {
                                selectedNetwork = network; showDetail = true
                            }
                            if !network.isBuiltin {
                                ActionButton(icon: "trash.fill", color: MacDockColors.destructive) {
                                    networkToDelete = network
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24).padding(.vertical, 14)
                    .contextMenu {
                        Button("Inspect") { selectedNetwork = network; showDetail = true }
                        if !network.isBuiltin {
                            Divider()
                            Button("Delete", role: .destructive) { networkToDelete = network }
                        }
                    }
                    if network.id != networkService.networks.last?.id {
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
            Image(systemName: "network").font(.system(size: 48)).foregroundStyle(MacDockColors.muted)
            Text("No networks").font(.headline).foregroundStyle(MacDockColors.mutedForeground)
            Text("Click \"New Network\" to create one").font(.caption).foregroundStyle(MacDockColors.muted)
        }.frame(maxWidth: .infinity).padding(.vertical, 60)
    }
}
