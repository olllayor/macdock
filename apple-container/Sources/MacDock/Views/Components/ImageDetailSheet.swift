import SwiftUI
import ContainerAPIClient

struct ImageDetailSheet: View {
    let image: ClientImage
    @Environment(\.dismiss) private var dismiss
    @SwiftUI.State private var fullSize: UInt64 = 0
    @SwiftUI.State private var isLoadingSize = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Image Details").font(.title2.bold()).foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(MacDockColors.muted)
                }.buttonStyle(.plain)
            }.padding(24)
            Divider().background(MacDockColors.border)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section("General") {
                        detailRow("Reference", image.reference)
                        detailRow("Digest", image.digest)
                    }
                    section("Size") {
                        if isLoadingSize {
                            ProgressView().frame(height: 20)
                        } else {
                            detailRow("Total Size", fullSize.byteCountFormatted)
                        }
                    }
                }.padding(24)
            }
        }
        .frame(width: 480, height: 360)
        .background(MacDockColors.background)
        .task { await loadSize() }
    }

    private func loadSize() async {
        isLoadingSize = true
        do {
            let size = try await ClientImage.getFullImageSize(image: image)
            fullSize = size >= 0 ? UInt64(size) : 0
        } catch {
            fullSize = 0
        }
        isLoadingSize = false
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
