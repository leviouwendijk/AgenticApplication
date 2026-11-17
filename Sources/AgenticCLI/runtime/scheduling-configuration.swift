import AgenticAppleServices
import AgenticRuntime
import AgenticScheduling
import Foundation

/// Scheduling for a session: the home's `domains/scheduling.frame` over
/// Apple Calendar, with addresses and travel times from Apple Maps. A
/// missing or invalid file does not stop the session; the scheduling tools
/// report it when used.
enum SchedulingConfigurationLoader {
    static func state(
        home: AgentHome = AgentHomeLocator().resolveHome()
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
                sources: [EventKitCalendarSource()],
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
