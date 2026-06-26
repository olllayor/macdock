import Foundation
import ContainerAPIClient
import Logging

@Observable @MainActor
final class DaemonService {
    private(set) var isRunning = false
    private(set) var health: SystemHealth?
    private let logger = Logger(label: "macdock.daemon")

    var version: String { health?.apiServerVersion ?? "unknown" }
    var build: String { health?.apiServerBuild ?? "unknown" }
    var dataRoot: String { health?.appRoot.path ?? "unknown" }
    var installRoot: String { health?.installRoot.path ?? "unknown" }

    func initialize() async {
        await ping()
        if !isRunning {
            await startDaemon()
        }
    }

    func ping() async {
        do {
            let result = try await ClientHealthCheck.ping()
            health = result
            isRunning = true
        } catch {
            isRunning = false
            health = nil
        }
    }

    func startDaemon() async {
        logger.info("Starting container-apiserver...")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["container", "system", "start"]
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                logger.info("Daemon started successfully")
                try? await Task.sleep(for: .seconds(2))
                await ping()
            } else {
                logger.error("Daemon failed to start with exit code \(process.terminationStatus)")
            }
        } catch {
            logger.error("Failed to launch daemon: \(error)")
        }
    }

    func stopDaemon() async {
        logger.info("Stopping container-apiserver...")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["container", "system", "stop"]
        do {
            try process.run()
            process.waitUntilExit()
            isRunning = false
            health = nil
            logger.info("Daemon stopped")
        } catch {
            logger.error("Failed to stop daemon: \(error)")
        }
    }
}
