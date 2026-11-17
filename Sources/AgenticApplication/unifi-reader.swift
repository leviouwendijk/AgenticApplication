import Foundation
import UniFi
import UniFiPlanning

public enum LocalFunc {}

extension LocalFunc {
    public struct UniFiReaderAPI {
        public init() {}

        func reader(
            gateway: URL
        ) throws -> UniFiPlanning.Reader {
            let client = try UniFi.Client.environment(gateway: gateway)
            return UniFiPlanning.Reader(client: client)
        }
    }

    public static var unifi: UniFiReaderAPI {
        return .init()
    }
}
