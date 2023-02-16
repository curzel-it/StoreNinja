import BareBones
import Foundation
import Schwifty

public protocol StoreVersionChecker {
    func storeVersion() async -> Result<String, StoreNinjaError>
    func isReleased(version: String) async -> ReleaseStatus
    func availableUpdate(from: String) async -> UpdateStatus
}

public enum ReleaseStatus: Equatable {
    case yes(isLatest: Bool)
    case no
    case unknown(error: StoreNinjaError?)
}

public enum UpdateStatus: Equatable {
    case updateAvailable(version: String)
    case noUpdatesAvailable
    case unknown(error: StoreNinjaError?)
}

public enum StoreNinjaError: Error {
    case unknown
    case couldNotAccessAppStorePage
    case couldNotParseAppStorePage
}

public extension StoreVersionChecker {
    func isCurrentVersionReleased() async -> ReleaseStatus {
        await isReleased(version: Bundle.main.appVersion ?? "")
    }
    
    func availableUpdateFromCurrentVersion() async -> UpdateStatus {
        await availableUpdate(from: Bundle.main.appVersion ?? "")
    }
}

public class StoreNinja {
    public static func checker(
        appId: String,
        additionalParsers: [StorePageParser] = [],
        versionsComparator: VersionsComparator? = nil
    ) -> StoreVersionChecker {
        StoreVersionCheckerImpl(
            appId: appId,
            parsers: [BasicParser()] + additionalParsers,
            versionsComparator: versionsComparator ?? BasicVersionsComparator()
        )
    }
}

class StoreVersionCheckerImpl: StoreVersionChecker {
    private let appId: String
    private let parsers: [StorePageParser]
    private let versionsComparator: any VersionsComparator
    
    init(appId: String, parsers: [StorePageParser], versionsComparator: any VersionsComparator) {
        self.appId = appId
        self.parsers = parsers
        self.versionsComparator = versionsComparator
    }
    
    func storeVersion() async -> Result<String, StoreNinjaError> {
        let pageUrl = "https://apps.apple.com/app/id\(appId)"
        let client = HttpClient(baseUrl: pageUrl)
        let response = await client.data(via: .get)
        return handle(appStoreResponse: response)
    }
    
    func isReleased(version: String) async -> ReleaseStatus {
        let storeVersion = await storeVersion()
        switch storeVersion {
        case .success(let store):
            if versionsComparator.compare(store, version) == .older {
                return .no
            }
            let isLatest = versionsComparator.compare(store, version) == .equivalent
            return .yes(isLatest: isLatest)
        case .failure(let error): return .unknown(error: error)
        }
    }
    
    func availableUpdate(from version: String) async -> UpdateStatus {
        let storeVersion = await storeVersion()
        switch storeVersion {
        case .success(let store):
            if versionsComparator.compare(store, version) == .newer {
                return .updateAvailable(version: store)
            } else {
                return .noUpdatesAvailable
            }
        case .failure(let failure):
            return .unknown(error: failure)
        }
    }
    
    func handle(appStoreResponse response: Result<Data, ApiError>) -> Result<String, StoreNinjaError> {
        switch response {
        case .success(let data):
            return handle(appStorePage: data)
        case .failure(let error):
            Logger.log("StoreNinja", "Could not access AppStore page \(error)")
            return .failure(.couldNotAccessAppStorePage)
        }
    }
    
    func handle(appStorePage data: Data) -> Result<String, StoreNinjaError> {
        guard let html = String(data: data, encoding: .utf8),
              let version = version(from: html) else {
            return .failure(.couldNotParseAppStorePage)
        }
        return .success(version)
    }
    
    func version(from html: String) -> String? {
        for parser in parsers {
            if let version = parser.version(from: html) {
                return version
            }
        }
        return nil
    }
}

private extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
