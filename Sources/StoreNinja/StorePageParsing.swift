import BareBones
import Foundation
import Schwifty

public protocol StorePageParser {
    func version(from rawHtml: String) -> String?
}

class BasicParser: StorePageParser {
    private let open = "whats-new__latest__version\">Version"
    private let close = "<"
    
    func version(from html: String) -> String? {
        guard html.contains(open) && html.contains(close) else {
            return nil
        }
        return html
            .components(separatedBy: open)
            .last?
            .components(separatedBy: close)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
