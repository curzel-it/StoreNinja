import BareBones
import Foundation
import Schwifty

public protocol VersionsComparator {
    func compare(_: String, _: String) -> VersionsComparisonResult
}

public enum VersionsComparisonResult {
    case newer
    case older
    case equivalent
}

class BasicVersionsComparator: VersionsComparator {
    func compare(_ version1: String, _ version2: String) -> VersionsComparisonResult {
        var numbers1 = numbers(from: version1)
        var numbers2 = numbers(from: version2)
        if numbers1.count > numbers2.count {
            numbers2 += [Int](repeating: 0, count: numbers1.count - numbers2.count)
        }
        if numbers2.count > numbers1.count {
            numbers1 += [Int](repeating: 0, count: numbers2.count - numbers1.count)
        }
        return compare(numbers1, numbers2)
    }
    
    func compare(_ version1: [Int], _ version2: [Int]) -> VersionsComparisonResult {
        for (a, b) in zip(version1, version2) {
            if a > b { return .newer }
            if b > a { return .older }
        }
        return .equivalent
    }
    
    func numbers(from version: String) -> [Int] {
        version
            .components(separatedBy: ".")
            .map { Int($0) ?? 0 }
    }
}
