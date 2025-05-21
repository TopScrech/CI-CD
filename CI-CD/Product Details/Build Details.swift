import ScrechKit
import AppStoreConnect_Swift_SDK
import Kingfisher

struct BuildDetails: View {
    @Environment(BuildVM.self) private var vm
    @Environment(\.openURL) private var openUrl
    
    private let build: CiBuildRun
    
    init(_ build: CiBuildRun) {
        self.build = build
    }
    
    private let imgSize = 32.0
    
    var body: some View {
        let commit = build.attributes?.sourceCommit
        let author = commit?.author
        
        List {
            Section {
                if let workflow = build.relationships?.workflow?.data {
                    Button {
                        Task {
                            try await vm.startRebuild(of: build.id, in: workflow.id)
                        }
                    } label: {
                        Label("Rebuild", systemImage: "hammer")
                    }
                    
                    Button {
                        Task {
                            try await vm.startRebuild(of: build.id, in: workflow.id, clean: true)
                        }
                    } label: {
                        Label("Rebuild clean", systemImage: "hammer")
                    }
                }
            }
            
            BuildDetailsProgress(build)
            
            Section {
                if let startedReason = build.attributes?.startReason {
                    ListParam("Reason", param: startedReason.rawValue.lowercased().capitalized)
                }
                
                if let created = build.attributes?.createdDate {
                    HStack {
                        Text("Created")
                        
                        Spacer()
                        
                        Text(created, format: .dateTime)
                            .secondary()
                    }
                }
                
                if let started = build.attributes?.startedDate {
                    HStack {
                        Text("Started")
                        
                        Spacer()
                        
                        Text(started, format: .dateTime)
                            .secondary()
                    }
                }
                
                if let finished = build.attributes?.finishedDate {
                    HStack {
                        Text("Finished")
                        
                        Spacer()
                        
                        Text(finished, format: .dateTime)
                            .secondary()
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        if let avatar = author?.avatarURL {
                            KFImage(avatar)
                                .resizable()
                                .frame(imgSize)
                                .clipShape(.circle)
                        }
                        
                        Text(author?.displayName ?? "-")
                        
                        Spacer()
                        
                        if let commit, let id = commit.commitSha?.prefix(7) {
                            Text(id)
                                .secondary()
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .background(.ultraThinMaterial, in: .capsule)
                        }
                    }
                    
                    Text(commit?.message ?? "-")
                        .monospaced()
                }
                
                if let commit, let url = commit.webURL {
                    Button {
                        openUrl(url)
                    } label: {
                        Label("Open on GitHub", systemImage: "link")
                    }
                    
                    ShareLink(item: url)
                }
            }
            
            Section("Build actions") {
                ForEach(vm.actions) { action in
                    ActionCard(action)
                }
            }
        }
        .navigationTitle("Build \(build.attributes?.number?.description ?? "")")
        .foregroundStyle(.foreground)
        .scrollIndicators(.never)
        .task {
            try? await vm.buildActions(build.id)
        }
    }
}

#Preview {
    BuildDetails(CiBuildRun.preview)
        .environment(BuildVM())
        .darkSchemePreferred()
}
