import SwiftUI

struct PullImageSheet: View {
    @Environment(ImageService.self) private var imageService
    @Environment(\.dismiss) private var dismiss
    @SwiftUI.State private var reference = ""
    @SwiftUI.State private var isPulling = false
    @SwiftUI.State private var statusText = ""

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Pull Image").font(.title2.bold()).foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(MacDockColors.muted)
                }.buttonStyle(.plain)
            }
            .padding(24)
            Divider().background(MacDockColors.border)

            VStack(alignment: .leading, spacing: 16) {
                Text("Image Reference").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                TextField("e.g. nginx:latest, ubuntu:24.04", text: $reference)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(MacDockColors.input)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(isPulling)

                if isPulling {
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(.linear)
                        Text(statusText).font(.caption).foregroundStyle(MacDockColors.mutedForeground)
                    }
                }
            }
            .padding(24)

            Spacer()
            Divider().background(MacDockColors.border)
            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .disabled(isPulling)
                Spacer()
                Button("Pull") { Task { await pull() } }
                    .buttonStyle(.plain)
                    .disabled(reference.isEmpty || isPulling)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(reference.isEmpty ? MacDockColors.muted : MacDockColors.accent)
                    .foregroundStyle(reference.isEmpty ? MacDockColors.mutedForeground : MacDockColors.accentForeground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }.padding(24)
        }
        .frame(width: 480, height: 300)
        .background(MacDockColors.background)
    }

    private func pull() async {
        isPulling = true
        statusText = "Pulling \(reference)..."
        do {
            _ = try await imageService.pull(reference: reference)
            statusText = "Pull complete!"
            try? await Task.sleep(for: .seconds(1))
            dismiss()
        } catch {
            statusText = "Error: \(error.localizedDescription)"
            isPulling = false
        }
    }
}
