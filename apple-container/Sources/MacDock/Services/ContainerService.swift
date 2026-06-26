import Foundation
import ContainerAPIClient
import ContainerResource
import Logging

@Observable @MainActor
final class ContainerService {
    private(set) var containers: [ContainerSnapshot] = []
    private let client = ContainerClient()

    var runningCount: Int {
        containers.filter { $0.status == .running }.count
    }

    var totalCount: Int { containers.count }

    func refresh() async {
        do {
            containers = try await client.list()
        } catch {
            print("Failed to list containers: \(error)")
        }
    }

    func createContainer(configuration: ContainerConfiguration) async throws {
        let kernel = try await ClientKernel.getDefaultKernel(for: .current)
        try await client.create(
            configuration: configuration,
            options: .default,
            kernel: kernel
        )
        await refresh()
    }

    func start(id: String) async throws {
        _ = try await client.bootstrap(id: id, stdio: [nil, nil, nil])
        await refresh()
    }

    func stop(id: String) async throws {
        try await client.stop(id: id)
        await refresh()
    }

    func delete(id: String) async throws {
        try await client.delete(id: id, force: true)
        await refresh()
    }

    func kill(id: String, signal: String = "SIGTERM") async throws {
        try await client.kill(id: id, signal: signal)
        await refresh()
    }

    func stats(id: String) async -> ContainerStats? {
        do {
            return try await client.stats(id: id)
        } catch {
            return nil
        }
    }

    func getLogs(id: String) async -> [String] {
        do {
            let handles = try await client.logs(id: id)
            guard let handle = handles.first else { return [] }
            let data = handle.readDataToEndOfFile()
            if let content = String(data: data, encoding: .utf8) {
                return content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            }
            return []
        } catch {
            return []
        }
    }

    func diskUsage(id: String) async -> UInt64 {
        do {
            return try await client.diskUsage(id: id)
        } catch {
            return 0
        }
    }
}
