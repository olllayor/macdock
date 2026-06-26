import Foundation
import ContainerAPIClient
import ContainerImagesServiceClient
import ContainerResource
import ContainerPersistence
import ContainerizationOCI
import Logging

@Observable @MainActor
final class ImageService {
    private(set) var images: [ClientImage] = []

    var totalCount: Int { images.count }

    func refresh() async {
        do {
            images = try await ClientImage.list()
        } catch {
            print("Failed to list images: \(error)")
        }
    }

    func fetch(reference: String) async throws -> ClientImage {
        return try await ClientImage.fetch(
            reference: reference,
            containerSystemConfig: ContainerSystemConfig()
        )
    }

    func pull(reference: String) async throws -> ClientImage {
        return try await ClientImage.pull(
            reference: reference,
            containerSystemConfig: ContainerSystemConfig()
        )
    }

    func delete(reference: String) async throws {
        try await ClientImage.delete(reference: reference)
        await refresh()
    }

    func getImageSize(image: ClientImage) async throws -> Int64 {
        return try await ClientImage.getFullImageSize(image: image)
    }
}
