import SwiftUI
import ContainerResource

struct CreateContainerSheet: View {
    @Environment(ContainerService.self) private var containerService
    @Environment(ImageService.self) private var imageService
    @Environment(\.dismiss) private var dismiss

    @SwiftUI.State private var selectedTab = 0
    @SwiftUI.State private var isCreating = false
    @SwiftUI.State private var imageRef = ""
    @SwiftUI.State private var containerName = ""
    @SwiftUI.State private var cpus = 4
    @SwiftUI.State private var memoryMB = 1024
    @SwiftUI.State private var envVars: [EnvVar] = []
    @SwiftUI.State private var portMappings: [PortMappingEntry] = []
    @SwiftUI.State private var networkName = ""
    @SwiftUI.State private var volumeMounts: [VolumeMountEntry] = []
    @SwiftUI.State private var readOnlyRootfs = false
    @SwiftUI.State private var sysctls: [SysctlEntry] = []
    @SwiftUI.State private var capAdd = ""
    @SwiftUI.State private var capDrop = ""
    @SwiftUI.State private var dnsNameservers = "1.1.1.1"
    @SwiftUI.State private var rosetta = false
    @SwiftUI.State private var useSSH = false
    @SwiftUI.State private var useInit = false

    let tabs = ["General", "Networking", "Storage", "Security", "Advanced"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("New Container").font(.title2.bold()).foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(MacDockColors.muted)
                }.buttonStyle(.plain)
            }.padding(24)
            Divider().background(MacDockColors.border)
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button { selectedTab = index } label: {
                        Text(tab)
                            .font(.system(.body, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundStyle(selectedTab == index ? MacDockColors.accent : MacDockColors.mutedForeground)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(selectedTab == index ? MacDockColors.accent.opacity(0.1) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 24).padding(.top, 16)
            Divider().background(MacDockColors.border)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch selectedTab {
                    case 0: generalTab
                    case 1: networkingTab
                    case 2: storageTab
                    case 3: securityTab
                    case 4: advancedTab
                    default: generalTab
                    }
                }.padding(24)
            }

            Divider().background(MacDockColors.border)
            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.plain)
                Spacer()
                Button("Create") { Task { await createContainer() } }
                    .buttonStyle(.plain)
                    .disabled(imageRef.isEmpty || isCreating)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(imageRef.isEmpty ? MacDockColors.muted : MacDockColors.accent)
                    .foregroundStyle(imageRef.isEmpty ? MacDockColors.mutedForeground : MacDockColors.accentForeground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }.padding(24)
        }
        .frame(width: 560, height: 640)
        .background(MacDockColors.background)
    }

    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            formField("Image") { TextField("e.g. nginx:latest", text: $imageRef).textFieldStyle(.plain).padding(10).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 8)) }
            formField("Name") { TextField("my-container", text: $containerName).textFieldStyle(.plain).padding(10).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 8)) }
            formField("CPUs") { Stepper("\(cpus)", value: $cpus, in: 1...16).foregroundStyle(MacDockColors.foreground) }
            formField("Memory (MB)") { Stepper("\(memoryMB) MB", value: $memoryMB, in: 128...16384, step: 128).foregroundStyle(MacDockColors.foreground) }
            envVarsSection
        }
    }

    private var envVarsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Environment Variables").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                Spacer()
                Button { envVars.append(EnvVar(key: "", value: "")) } label: { Image(systemName: "plus.circle").foregroundStyle(MacDockColors.accent) }.buttonStyle(.plain)
            }
            ForEach($envVars) { $env in
                HStack(spacing: 8) {
                    TextField("KEY", text: $env.key).textFieldStyle(.plain).padding(8).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 6))
                    TextField("value", text: $env.value).textFieldStyle(.plain).padding(8).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 6))
                    Button { envVars.removeAll { $0.id == env.id } } label: { Image(systemName: "minus.circle").foregroundStyle(MacDockColors.destructive) }.buttonStyle(.plain)
                }
            }
        }
    }

    private var networkingTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            formField("Network") { TextField("default (optional)", text: $networkName).textFieldStyle(.plain).padding(10).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 8)) }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Port Mappings").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                    Spacer()
                    Button { portMappings.append(PortMappingEntry(hostPort: "", containerPort: "", proto: "tcp")) } label: { Image(systemName: "plus.circle").foregroundStyle(MacDockColors.accent) }.buttonStyle(.plain)
                }
                ForEach($portMappings) { $port in
                    HStack(spacing: 8) {
                        TextField("Host", text: $port.hostPort).textFieldStyle(.plain).padding(8).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 6))
                        Text("->").foregroundStyle(MacDockColors.muted)
                        TextField("Container", text: $port.containerPort).textFieldStyle(.plain).padding(8).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 6))
                        Button { portMappings.removeAll { $0.id == port.id } } label: { Image(systemName: "minus.circle").foregroundStyle(MacDockColors.destructive) }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var storageTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Read-only root filesystem", isOn: $readOnlyRootfs).foregroundStyle(MacDockColors.foreground)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Volume Mounts").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                    Spacer()
                    Button { volumeMounts.append(VolumeMountEntry(source: "", destination: "", readOnly: false)) } label: { Image(systemName: "plus.circle").foregroundStyle(MacDockColors.accent) }.buttonStyle(.plain)
                }
                ForEach($volumeMounts) { $mount in
                    HStack(spacing: 8) {
                        TextField("Source", text: $mount.source).textFieldStyle(.plain).padding(8).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 6))
                        Text("->").foregroundStyle(MacDockColors.muted)
                        TextField("Destination", text: $mount.destination).textFieldStyle(.plain).padding(8).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 6))
                        Button { volumeMounts.removeAll { $0.id == mount.id } } label: { Image(systemName: "minus.circle").foregroundStyle(MacDockColors.destructive) }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var securityTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            formField("Cap Add") { TextField("e.g. NET_ADMIN, SYS_PTRACE", text: $capAdd).textFieldStyle(.plain).padding(10).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 8)) }
            formField("Cap Drop") { TextField("e.g. ALL", text: $capDrop).textFieldStyle(.plain).padding(10).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 8)) }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Sysctls").font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
                    Spacer()
                    Button { sysctls.append(SysctlEntry(key: "", value: "")) } label: { Image(systemName: "plus.circle").foregroundStyle(MacDockColors.accent) }.buttonStyle(.plain)
                }
                ForEach($sysctls) { $s in
                    HStack(spacing: 8) {
                        TextField("key", text: $s.key).textFieldStyle(.plain).padding(8).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 6))
                        TextField("value", text: $s.value).textFieldStyle(.plain).padding(8).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 6))
                        Button { sysctls.removeAll { $0.id == s.id } } label: { Image(systemName: "minus.circle").foregroundStyle(MacDockColors.destructive) }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var advancedTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            formField("DNS Nameservers") { TextField("1.1.1.1", text: $dnsNameservers).textFieldStyle(.plain).padding(10).background(MacDockColors.input).clipShape(RoundedRectangle(cornerRadius: 8)) }
            Divider().background(MacDockColors.border)
            Toggle("Enable Rosetta x86-64 translation", isOn: $rosetta).foregroundStyle(MacDockColors.foreground)
            Toggle("Enable SSH agent forwarding", isOn: $useSSH).foregroundStyle(MacDockColors.foreground)
            Toggle("Use minimal init process", isOn: $useInit).foregroundStyle(MacDockColors.foreground)
        }
    }

    private func formField(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline.weight(.medium)).foregroundStyle(MacDockColors.foreground)
            content()
        }
    }

    private func createContainer() async {
        isCreating = true
        defer { isCreating = false }
        do {
            let image = try await imageService.fetch(reference: imageRef)
            let processConfig = ProcessConfiguration(
                executable: "/bin/sh",
                arguments: ["-c", "sleep infinity"],
                environment: envVars.map { "\($0.key)=\($0.value)" },
                workingDirectory: "/"
            )
            var resources = ContainerConfiguration.Resources()
            resources.cpus = cpus
            resources.memoryInBytes = UInt64(memoryMB) * 1_048_576

            let config = ContainerConfiguration(
                id: containerName.isEmpty ? UUID().uuidString.prefix(12).lowercased() : containerName,
                image: image.description,
                process: processConfig
            )
            var c = config
            c.resources = resources
            c.readOnly = readOnlyRootfs
            c.rosetta = rosetta
            c.ssh = useSSH
            c.useInit = useInit
            if !capAdd.isEmpty { c.capAdd = capAdd.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
            if !capDrop.isEmpty { c.capDrop = capDrop.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
            if !dnsNameservers.isEmpty { c.dns = ContainerConfiguration.DNSConfiguration(nameservers: dnsNameservers.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }) }
            for s in sysctls where !s.key.isEmpty { c.sysctls[s.key] = s.value }
            try await containerService.createContainer(configuration: c)
            dismiss()
        } catch {
            print("Failed to create container: \(error)")
        }
    }
}

struct EnvVar: Identifiable { let id = UUID(); var key: String; var value: String }
struct PortMappingEntry: Identifiable { let id = UUID(); var hostPort: String; var containerPort: String; var proto: String }
struct VolumeMountEntry: Identifiable { let id = UUID(); var source: String; var destination: String; var readOnly: Bool }
struct SysctlEntry: Identifiable { let id = UUID(); var key: String; var value: String }
