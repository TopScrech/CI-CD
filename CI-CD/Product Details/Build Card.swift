import ScrechKit
import Kingfisher
import AppStoreConnect_Swift_SDK

struct BuildCard: View {
    @State private var vm = BuildVM()
    @Environment(AppVM.self) private var productVM
    @EnvironmentObject private var store: ValueStore
    
    private let build: CiBuildRun
    
    init(_ build: CiBuildRun) {
        self.build = build
    }
    
    private var statusColor: Color {
        switch build.attributes?.completionStatus {
        case .succeeded: .green
        case .failed, .errored: .red
        case .canceled, .skipped: .gray
            
        default:
#if os(macOS)
            Color(nsColor: .darkGray)
#else
            Color(uiColor: .darkGray)
#endif
        }
    }
    
    private let imgSize = 32.0
    
    var body: some View {
        let commit = build.attributes?.sourceCommit
        let author = commit?.author
        
        NavigationLink {
            BuildDetails(build)
                .environment(vm)
        } label: {
            HStack {
                Capsule()
                    .frame(width: 5)
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(statusColor.gradient)
                    .padding(.vertical, 5)
                
                VStack(alignment: .leading) {
                    HStack {
                        if let build = build.attributes?.number {
                            Text("Build \(build)")
                                .title3(.semibold, design: .rounded)
                        }
                        
                        if let commit, let id = commit.commitSha?.prefix(7) {
                            Text(id)
                                .secondary()
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .background(.ultraThinMaterial, in: .capsule)
                        }
                        
                        
                        if let minDiff = timeDiffISO(date1: build.attributes?.createdDate, date2: build.attributes?.startedDate) {
                            HStack(spacing: 2) {
                                Image(systemName: "clock")
                                
                                Text("\(minDiff)m")
                            }
                            .secondary()
                            .padding(.vertical, 2)
                            .padding(.horizontal, 3)
                            .padding(.trailing, 4)
                            .background(.ultraThinMaterial, in: .capsule)
                        }
                        
                        Text(timeSinceISO(build.attributes?.createdDate))
                            .secondary()
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(.ultraThinMaterial, in: .capsule)
                    }
                    
                    if let message = commit?.message {
                        Text(message)
                    }
                    
                    HStack {
                        if let avatar = author?.avatarURL {
                            KFImage(avatar)
                                .resizable()
                                .frame(imgSize)
                                .clipShape(.circle)
                        }
                        
                        Text(author?.displayName ?? "-")
                    }
                }
            }
        }
        .monospacedDigit()
        .padding(.leading, -8)
        .contextMenu {
            if let workflow = build.relationships?.workflow?.data {
                Button("Rebuild", systemImage: "hammer") {
                    if store.demoMode {
                        if let build = productVM.builds.first {
                            productVM.builds.append(build)
                        }
                    } else {
                        Task {
                            try await vm.startRebuild(of: build.id, in: workflow.id)
                        }
                    }
                }
                
                Button("Rebuild clean", systemImage: "hammer") {
                    if store.demoMode {
                        if let build = productVM.builds.first {
                            productVM.builds.append(build)
                        }
                    } else {
                        Task {
                            try await vm.startRebuild(
                                of: build.id,
                                in: workflow.id,
                                clean: true
                            )
                        }
                    }
                }
            }
#if DEBUG
            Section {
                Button {
                    Pasteboard.copy(build.id)
                } label: {
                    Text("Copy build id")
                    
                    Text(build.id)
                    
                    Image(systemName: "hammer")
                }
            }
#endif
        }
    }
    
    private func timeDiffISO(date1: Date?, date2: Date?) -> Int? {
        guard let date1, let date2 else {
            return nil
        }
        
        let secDiff = date2.timeIntervalSince(date1)
        let minDiff = Int(secDiff / 60)
        
        return minDiff < 0 ? minDiff * -1 : minDiff
    }
    
    private func timeSinceISO(_ date: Date?) -> LocalizedStringKey {
        guard let date else {
            return ""
        }
        
        let sinceNowSeconds = Int(date.timeIntervalSinceNow * -1)
        
        guard sinceNowSeconds > 1 else {
            return "Now"
        }
        
        guard sinceNowSeconds > 60 else {
            return "\(sinceNowSeconds)s ago"
        }
        
        let sinceNowMinutes = sinceNowSeconds / 60
        guard sinceNowMinutes > 60 else {
            return "\(sinceNowMinutes)m ago"
        }
        
        let sinceNowHours = sinceNowMinutes / 60
        guard sinceNowHours > 24 else {
            return "\(sinceNowHours)h ago"
        }
        
        let sinceNowDays = sinceNowHours / 24
        return "\(sinceNowDays)d ago"
    }
}

#Preview {
    NavigationView {
        List {
            NavigationLink {
                
            } label: {
                BuildCard(CiBuildRun.preview)
            }
        }
    }
    .darkSchemePreferred()
}
