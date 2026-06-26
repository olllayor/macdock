import SwiftUI
import ContainerResource

struct VolumeDetailSheet: View {
    let volume: VolumeConfiguration
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Volume Details").font(.title2.bold()).foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(MacDockColors.muted)
                }.buttonStyle(.plain)
            }.padding(24)
            Divider().background(MacDockColors.border)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section("General") {
                        detailRow("Name", volume.name)
                        detailRow("Driver", volume.driver)
                        detailRow("Format", volume.format)
                        detailRow("Source", volume.source)
                        detailRow("Created", volume.creationDate.formatted())
                    }
                    if !volume.labels.isEmpty {
                        section("Labels") {
                            ForEach(volume.labels.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                detailRow(key, value)
                            }
                        }
                    }
                    if let size = volume.sizeInBytes {
                        section("Size") {
                            detailRow("Size", size.byteCountFormatted)
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
