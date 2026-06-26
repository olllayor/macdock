import Foundation
import ContainerAPIClient
import ContainerResource
import Logging

@Observable @MainActor
final class DiskUsageService {
    private(set) var stats: DiskUsageStats?
    private let logger = Logger(label: "macdock.diskusage")

    var imagesSize: UInt64 { stats?.images.sizeInBytes ?? 0 }
    var containersSize: UInt64 { stats?.containers.sizeInBytes ?? 0 }
    var volumesSize: UInt64 { stats?.volumes.sizeInBytes ?? 0 }

    var imagesReclaimable: UInt64 { stats?.images.reclaimable ?? 0 }
    var containersReclaimable: UInt64 { stats?.containers.reclaimable ?? 0 }
    var volumesReclaimable: UInt64 { stats?.volumes.reclaimable ?? 0 }

    func refresh() async {
        do {
            stats = try await ClientDiskUsage.get()
        } catch {
            logger.error("Failed to get disk usage: \(error)")
        }
    }
}

extension UInt64 {
    var byteCountFormatted: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(self))
    }
}
