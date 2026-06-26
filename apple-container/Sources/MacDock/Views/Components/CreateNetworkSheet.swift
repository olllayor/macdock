import SwiftUI
import ContainerResource

struct CreateNetworkSheet: View {
    @Environment(NetworkService.self) private var networkService
    @Environment(\.dismiss) private var dismiss
    @SwiftUI.State private var name = ""
    @SwiftUI.State private var mode = "nat"
    @SwiftUI.State private var isCreating = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("New Network").font(.title2.bold()).foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(MacDockColors.muted)
                }.buttonStyle(.plain)
            }.padding(24)
            Divider().background(MacDockColors.border)

            VStack(alignment: .leading, spacing: 16) {
                Text("Name").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                TextField("my-network", text: $name)
                    .textFieldStyle(.plain).padding(10)
                    .background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 8))

                Text("Mode").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                Picker("Mode", selection: $mode) {
                    Text("NAT").tag("nat")
                    Text("Host Only").tag("hostOnly")
                }
                .pickerStyle(.segmented)

                Text("NAT: containers get routable IPs via host translation").font(.caption).foregroundStyle(MacDockColors.mutedForeground)
            }
            .padding(24)

            Spacer()
            Divider().background(MacDockColors.border)
            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.plain)
                Spacer()
                Button("Create") { Task { await create() } }
                    .buttonStyle(.plain)
                    .disabled(name.isEmpty || isCreating)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(name.isEmpty ? MacDockColors.muted : MacDockColors.accent)
                    .foregroundStyle(name.isEmpty ? MacDockColors.mutedForeground : MacDockColors.accentForeground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }.padding(24)
        }
        .frame(width: 440, height: 380)
        .background(MacDockColors.background)
    }

    private func create() async {
        isCreating = true
        defer { isCreating = false }
        do {
            let networkMode = NetworkMode(mode) ?? .nat
            try await networkService.create(name: name, mode: networkMode)
            dismiss()
        } catch {
            print("Failed to create network: \(error)")
        }
    }
}
