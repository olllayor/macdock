import SwiftUI

struct CreateVolumeSheet: View {
    @Environment(VolumeService.self) private var volumeService
    @Environment(\.dismiss) private var dismiss
    @SwiftUI.State private var name = ""
    @SwiftUI.State private var driver = "local"
    @SwiftUI.State private var isCreating = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("New Volume").font(.title2.bold()).foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(MacDockColors.muted)
                }.buttonStyle(.plain)
            }.padding(24)
            Divider().background(MacDockColors.border)

            VStack(alignment: .leading, spacing: 16) {
                Text("Name").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                TextField("my-volume", text: $name)
                    .textFieldStyle(.plain).padding(10)
                    .background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 8))

                Text("Driver").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                Picker("Driver", selection: $driver) {
                    Text("local").tag("local")
                }
                .pickerStyle(.segmented)
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
        .frame(width: 440, height: 340)
        .background(MacDockColors.background)
    }

    private func create() async {
        isCreating = true
        defer { isCreating = false }
        do {
            try await volumeService.create(name: name, driver: driver)
            dismiss()
        } catch {
            print("Failed to create volume: \(error)")
        }
    }
}
