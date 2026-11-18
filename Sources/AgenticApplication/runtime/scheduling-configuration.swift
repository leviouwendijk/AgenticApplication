import AgenticAppleServices
import AgenticRuntime
import AgenticScheduling
import Foundation
import IO

/// Scheduling for a session: the home's `domains/scheduling.frame` over
/// Apple Calendar, with addresses and travel times from Apple Maps. A
/// missing or invalid file does not stop the session; the scheduling tools
/// report it when used, and the Configurator can still list calendars and
/// write the file.
enum SchedulingConfigurationLoader {
    static func store(
        home: AgentHome = AgentHomeLocator().resolveHome()
    ) -> Scheduling.ConfigurationStore {
        let sources: [any CalendarSource] = [EventKitCalendarSource()]
        let cache = LoadedState()
        let file = home.layout.domainfile(SchedulingFrame.fileName)
        return .init(
            file: file,
            archiveDirectory: home.layout.archivedir,
            sources: sources
        ) {
            cache.state(for: file) {
                state(home: home, sources: sources)
            }
        }
    }

    static func state(
        home: AgentHome = AgentHomeLocator().resolveHome(),
        sources: [any CalendarSource] = [EventKitCalendarSource()]
    ) -> Scheduling.ConfigurationState {
        let file = home.layout.domainfile(SchedulingFrame.fileName)
        do {
            guard let document = try home.domainDocument(
                SchedulingFrame.fileName,
                environment: SchedulingFrame.environment
            ) else {
                return .missing(expected: file.path)
            }
            let configuration = try SchedulingConfiguration(document: document)
            return .loaded(configuration.runtime(
                sources: sources,
                resolver: MapKitPlaceResolver(
                    cacheFile: home.layout.runtimeStorage.cachedir
                        .appendingPathComponent("scheduling-places.json")
                ),
                travel: MapKitTravelEstimator()
            ))
        } catch {
            return .invalid(
                file: file.path,
                message: (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            )
        }
    }
}

/// The last loaded state, kept until the file changes, so every tool call
/// sees a saved file without reloading an unchanged one.
private final class LoadedState: @unchecked Sendable {
    private let lock = NSLock()
    private var modified: Date??
    private var loaded: Scheduling.ConfigurationState?

    func state(
        for file: URL,
        load: () -> Scheduling.ConfigurationState
    ) -> Scheduling.ConfigurationState {
        let current = (try? FileInspector(file).inspect())?.modifiedAt
        lock.lock()
        defer { lock.unlock() }
        if let loaded, modified == .some(current) {
            return loaded
        }
        let state = load()
        loaded = state
        modified = .some(current)
        return state
    }
}
