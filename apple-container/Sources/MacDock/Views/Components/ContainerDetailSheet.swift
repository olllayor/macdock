import SwiftUI
import ContainerResource

struct ContainerDetailSheet: View {
    let container: ContainerSnapshot
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Container Details")
                    .font(.title2.bold())
                    .foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(MacDockColors.muted)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            Divider().background(MacDockColors.border)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section("General") {
                        detailRow("ID", container.id)
                        detailRow("Image", container.configuration.image.reference)
                        detailRow("Status", container.status.rawValue.capitalized)
                        if let started = container.startedDate {
                            detailRow("Started", started.formatted(.relative(presentation: .named)))
                        }
                        detailRow("Created", container.configuration.creationDate.formatted())
                    }
                    section("Resources") {
                        detailRow("CPUs", "\(container.configuration.resources.cpus)")
                        detailRow("Memory", container.configuration.resources.memoryInBytes.byteCountFormatted)
                        if let storage = container.configuration.resources.storage {
                            detailRow("Storage", storage.byteCountFormatted)
                        }
                    }
                    if !container.configuration.publishedPorts.isEmpty {
                        section("Ports") {
                            ForEach(container.configuration.publishedPorts.indices, id: \.self) { i in
                                let port = container.configuration.publishedPorts[i]
                                detailRow("Port", "\(port.hostPort) -> \(port.containerPort)/\(port.proto.rawValue)")
                            }
                        }
                    }
                    if !container.configuration.mounts.isEmpty {
                        section("Mounts") {
                            ForEach(container.configuration.mounts, id: \.destination) { mount in
                                detailRow(mount.source, mount.destination)
                            }
                        }
                    }
                    if !container.configuration.networks.isEmpty {
                        section("Networks") {
                            ForEach(container.configuration.networks, id: \.network) { net in
                                detailRow("Network", net.network)
                            }
                        }
                    }
                    if !container.configuration.labels.isEmpty {
                        section("Labels") {
                            ForEach(container.configuration.labels.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                detailRow(key, value)
                            }
                        }
                    }
                    if !container.configuration.sysctls.isEmpty {
                        section("Sysctls") {
                            ForEach(container.configuration.sysctls.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                detailRow(key, value)
                            }
                        }
                    }
                    section("Security") {
                        if !container.configuration.capAdd.isEmpty {
                            detailRow("Cap Add", container.configuration.capAdd.joined(separator: ", "))
                        }
                        if !container.configuration.capDrop.isEmpty {
                            detailRow("Cap Drop", container.configuration.capDrop.joined(separator: ", "))
                        }
                        detailRow("Rosetta", container.configuration.rosetta ? "Yes" : "No")
                        detailRow("SSH", container.configuration.ssh ? "Yes" : "No")
                        detailRow("Read Only", container.configuration.readOnly ? "Yes" : "No")
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 500, height: 600)
        .background(MacDockColors.background)
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline).foregroundStyle(MacDockColors.foreground)
            content()
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(MacDockColors.mutedForeground)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(MacDockColors.foreground)
                .textSelection(.enabled)
            Spacer()
        }
    }
}
