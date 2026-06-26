import SwiftUI
import ContainerResource

struct NetworkDetailSheet: View {
    let network: NetworkResource
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Network Details").font(.title2.bold()).foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(MacDockColors.muted)
                }.buttonStyle(.plain)
            }.padding(24)
            Divider().background(MacDockColors.border)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section("General") {
                        detailRow("Name", network.name)
                        detailRow("Plugin", network.configuration.plugin)
                        detailRow("Mode", network.configuration.mode.rawValue)
                        detailRow("Created", network.configuration.creationDate.formatted())
                        detailRow("Builtin", network.isBuiltin ? "Yes" : "No")
                    }
                    section("Network") {
                        detailRow("Subnet", network.status.ipv4Subnet.description)
                        detailRow("Gateway", network.status.ipv4Gateway.description)
                        if let ipv6 = network.status.ipv6Subnet {
                            detailRow("IPv6", ipv6.description)
                        }
                    }
                }.padding(24)
            }
        }
        .frame(width: 480, height: 400)
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
            Text(label).font(.subheadline).foregroundStyle(MacDockColors.mutedForeground).frame(width: 100, alignment: .leading)
            Text(value).font(.system(.body, design: .monospaced)).foregroundStyle(MacDockColors.foreground).textSelection(.enabled)
            Spacer()
        }
    }
}
