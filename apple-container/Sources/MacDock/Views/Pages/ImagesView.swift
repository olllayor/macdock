import SwiftUI
import ContainerAPIClient
import ContainerImagesServiceClient

struct ImagesView: View {
    @Environment(ImageService.self) private var imageService
    @SwiftUI.State private var showPullSheet = false
    @SwiftUI.State private var selectedImage: ClientImage?
    @SwiftUI.State private var showDetail = false
    @SwiftUI.State private var imageToDelete: ClientImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { header; content }
        }
        .background(MacDockColors.background)
        .task { await imageService.refresh() }
        .sheet(isPresented: $showPullSheet) { PullImageSheet() }
        .sheet(isPresented: $showDetail) {
            if let img = selectedImage { ImageDetailSheet(image: img) }
        }
        .alert("Delete Image", isPresented: Binding(
            get: { imageToDelete != nil },
            set: { if !$0 { imageToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { imageToDelete = nil }
            Button("Delete", role: .destructive) {
                if let img = imageToDelete { Task { try? await imageService.delete(reference: img.reference) } }
                imageToDelete = nil
            }
        } message: { Text("Delete \(imageToDelete?.reference ?? "")? This cannot be undone.") }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Images").font(.system(size: 28, weight: .bold)).foregroundStyle(MacDockColors.foreground)
                Text("OCI images from registries").font(.subheadline).foregroundStyle(MacDockColors.mutedForeground)
            }
            Spacer()
            Button { showPullSheet = true } label: {
                Label("Pull Image", systemImage: "plus")
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
                Text("Repository").headerCell().frame(width: 200, alignment: .leading)
                Text("Digest").headerCell()
                Spacer()
                Text("Actions").headerCell().frame(width: 80, alignment: .leading)
            }
            .padding(.horizontal, 24).padding(.vertical, 14)
            .background(MacDockColors.muted.opacity(0.3))
            Divider().background(MacDockColors.border)

            if imageService.images.isEmpty {
                emptyState
            } else {
                ForEach(imageService.images, id: \.digest) { image in
                    HStack(spacing: 16) {
                        Text(image.reference).font(.system(.body, weight: .medium)).foregroundStyle(MacDockColors.foreground).frame(width: 200, alignment: .leading).lineLimit(1)
                        Text(image.digest).font(.system(.caption, design: .monospaced)).foregroundStyle(MacDockColors.mutedForeground).lineLimit(1)
                        Spacer()
                        HStack(spacing: 4) {
                            ActionButton(icon: "info.circle", color: MacDockColors.chartBlue) {
                                selectedImage = image; showDetail = true
                            }
                            ActionButton(icon: "trash.fill", color: MacDockColors.destructive) {
                                imageToDelete = image
                            }
                        }
                    }
                    .padding(.horizontal, 24).padding(.vertical, 14)
                    .contextMenu {
                        Button("Inspect") { selectedImage = image; showDetail = true }
                        Divider()
                        Button("Delete", role: .destructive) { imageToDelete = image }
                    }
                    if image.digest != imageService.images.last?.digest {
                        Divider().background(MacDockColors.border).padding(.leading, 24)
                    }
                }
            }
        }
        .padding(.horizontal, 32).background(MacDockColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MacDockColors.border, lineWidth: 1))
        .padding(.horizontal, 32)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "opticaldisc").font(.system(size: 48)).foregroundStyle(MacDockColors.muted)
            Text("No images").font(.headline).foregroundStyle(MacDockColors.mutedForeground)
            Text("Click \"Pull Image\" to get started").font(.caption).foregroundStyle(MacDockColors.muted)
        }.frame(maxWidth: .infinity).padding(.vertical, 60)
    }
}
