#if canImport(SwiftUI)
import SwiftUI
import LocationHistoryConsumerAppSupport
import LocationHistoryConsumerDemoSupport
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

struct AppShellRootView: View {
    @State private var session = AppSessionState()
    @State private var isImportingFile = false

    var body: some View {
        Group {
            if session.content != nil {
                AppContentSplitView(
                    session: $session,
                    sourceHint: "Open app_export.json replaces the current content. Load Demo switches back to the bundled sample."
                )
            } else if session.isLoading {
                ProgressView("Opening app export...")
            } else {
                AppShellEmptyStateView(
                    message: session.message,
                    openAction: { isImportingFile = true },
                    loadDemoAction: loadBundledDemo
                )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Open app_export.json") {
                    isImportingFile = true
                }
                Button("Load Demo Data") {
                    loadBundledDemo()
                }
            }
        }
        #if canImport(UniformTypeIdentifiers)
        .fileImporter(
            isPresented: $isImportingFile,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false,
            onCompletion: handleImportResult
        )
        #endif
    }

    private func loadBundledDemo() {
        session.beginLoading()
        do {
            session.show(content: try DemoDataLoader.loadDefaultContent())
        } catch {
            session.showFailure(
                title: "Unable to load demo data",
                message: error.localizedDescription,
                preserveCurrentContent: session.hasLoadedContent
            )
        }
    }

    #if canImport(UniformTypeIdentifiers)
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            guard let url = urls.first else {
                return
            }
            session.beginLoading()
            loadImportedFile(at: url)
        case let .failure(error):
            if isUserCancelled(error) {
                return
            }
            session.showFailure(
                title: "Unable to open app export",
                message: error.localizedDescription,
                preserveCurrentContent: session.hasLoadedContent
            )
        }
    }

    private func loadImportedFile(at url: URL) {
        let accessedSecurityScope = url.startAccessingSecurityScopedResource()
        defer {
            if accessedSecurityScope {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            session.show(content: try AppContentLoader.loadImportedContent(from: url))
        } catch {
            session.showFailure(
                title: "Unable to open app export",
                message: error.localizedDescription,
                preserveCurrentContent: session.hasLoadedContent
            )
        }
    }

    private func isUserCancelled(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSCocoaErrorDomain && nsError.code == NSUserCancelledError
    }
    #endif
}

private struct AppShellEmptyStateView: View {
    let message: AppUserMessage?
    let openAction: () -> Void
    let loadDemoAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Location History Consumer")
                    .font(.title2.weight(.semibold))
                Text("Open a local app_export.json file to inspect overview, day summaries and day details offline.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            if let message {
                AppMessageCard(message: message)
            }

            VStack(alignment: .leading, spacing: 10) {
                Button("Open app_export.json", action: openAction)
                    .buttonStyle(.borderedProminent)
                Button("Load Demo Data", action: loadDemoAction)
                    .buttonStyle(.bordered)
                Text("This shell remains consumer-only. It does not import Google raw exports, store files, or use cloud services.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: 520, alignment: .leading)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
#endif
