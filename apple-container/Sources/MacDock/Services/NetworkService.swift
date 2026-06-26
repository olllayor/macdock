import Foundation
import ContainerAPIClient
import ContainerResource
import Logging

@Observable @MainActor
final class NetworkService {
    private(set) var networks: [NetworkResource] = []
    private let client = NetworkClient()

    var totalCount: Int { networks.count }

    func refresh() async {
        do {
            networks = try await client.list()
        } catch {
            print("Failed to list networks: \(error)")
        }
    }

    func delete(id: String) async throws {
        try await client.delete(id: id)
        await refresh()
    }

    func create(name: String, mode: NetworkMode = .nat) async throws {
        let config = try NetworkConfiguration(
            name: name,
            mode: mode,
            plugin: "container-network-vmnet"
        )
        _ = try await client.create(configuration: config)
        await refresh()
    }
}
