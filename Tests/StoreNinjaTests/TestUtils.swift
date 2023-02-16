import Foundation

extension Bundle {
    func urlForHtmlFile(named name: String) -> URL? {
        url(forResource: name, withExtension: "html", subdirectory: "Resources")
    }
}
