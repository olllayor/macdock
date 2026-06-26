import SwiftUI

struct LogsSheet: View {
    let containerId: String
    @Environment(ContainerService.self) private var containerService
    @Environment(\.dismiss) private var dismiss
    @SwiftUI.State private var logs: [String] = []
    @SwiftUI.State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Logs - \(containerId)")
                    .font(.title2.bold())
                    .foregroundStyle(MacDockColors.foreground)
                    .lineLimit(1)
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

            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 2) {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).padding(40)
                    } else if logs.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "text.alignleft").font(.system(size: 36)).foregroundStyle(MacDockColors.muted)
                            Text("No logs available").font(.headline).foregroundStyle(MacDockColors.mutedForeground)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity).padding(40)
                    } else {
                        ForEach(Array(logs.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(MacDockColors.foreground)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.black.opacity(0.3))

            Divider().background(MacDockColors.border)
            HStack {
                Text("\(logs.count) lines").font(.caption).foregroundStyle(MacDockColors.mutedForeground)
                Spacer()
                Button("Refresh") { Task { await loadLogs() } }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(MacDockColors.secondary).foregroundStyle(MacDockColors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .padding(16)
        }
        .frame(width: 700, height: 500)
        .background(MacDockColors.background)
        .task { await loadLogs() }
    }

    private func loadLogs() async {
        isLoading = true
        defer { isLoading = false }
        logs = await containerService.getLogs(id: containerId)
    }
}
