import Foundation
import ContainerAPIClient
import ContainerResource
import Logging

@Observable @MainActor
final class VolumeService {
    private(set) var volumes: [VolumeConfiguration] = []

    var totalCount: Int { volumes.count }

    func refresh() async {
        do {
            volumes = try await ClientVolume.list()
        } catch {
            print("Failed to list volumes: \(error)")
        }
    }

    func create(name: String, driver: String = "local") async throws {
        _ = try await ClientVolume.create(name: name, driver: driver)
        await refresh()
    }

    func delete(name: String) async throws {
        try await ClientVolume.delete(name: name)
        await refresh()
    }

    func diskUsage(name: String) async -> UInt64 {
        do {
            return try await ClientVolume.volumeDiskUsage(name: name)
        } catch {
            return 0
        }
    }
}
