#if canImport(SwiftUI)
import SwiftUI
import LocationHistoryConsumer
import LocationHistoryConsumerDemoSupport

struct RootView: View {
    @State private var state: LoadState = .loading
    @State private var selectedDate: String?

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView("Loading demo fixture...")
            case let .failed(message):
                ContentUnavailableView("Unable to load demo fixture", systemImage: "exclamationmark.triangle", description: Text(message))
            case let .loaded(content):
                NavigationSplitView {
                    DayListView(
                        summaries: content.daySummaries,
                        selectedDate: $selectedDate
                    )
                    .navigationTitle("Days")
                } detail: {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            OverviewSection(overview: content.overview)
                            DayDetailView(detail: content.detail(for: selectedDate))
                        }
                        .padding()
                    }
                    .navigationTitle(selectedDate ?? "Overview")
                }
                .task {
                    if selectedDate == nil {
                        selectedDate = content.selectedDate
                    }
                }
            }
        }
        .task {
            guard case .loading = state else { return }
            do {
                let content = try DemoDataLoader.loadDefaultContent()
                state = .loaded(content)
                selectedDate = content.selectedDate
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }
}

private enum LoadState {
    case loading
    case loaded(DemoContent)
    case failed(String)
}
#endif
