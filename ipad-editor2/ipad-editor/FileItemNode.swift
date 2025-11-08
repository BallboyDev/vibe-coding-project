import Foundation
import Combine

// MARK: - Data Model (Class-based for Tree Structure)
class FileItemNode: Identifiable, Hashable, ObservableObject {
    static func == (lhs: FileItemNode, rhs: FileItemNode) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    let id: URL
    @Published var url: URL
    @Published var name: String
    let isFolder: Bool
    let isTextFile: Bool
    let isMarkdown: Bool
    
    @Published var children: [FileItemNode]?
    @Published var isExpanded: Bool = false

    init(url: URL) {
        self.id = url
        self.url = url
        self.name = url.lastPathComponent.starts(with: ".") ? String(url.lastPathComponent.dropFirst()) : url.lastPathComponent
        
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        self.isFolder = isDirectory.boolValue
        
        let textFileExtensions: Set<String> = ["txt", "md", "markdown", "json", "js", "ts", "py", "rb", "swift", "java", "c", "cpp", "h", "hpp", "html", "css", "xml", "yml", "yaml", "sh"]
        let markdownExtensions: Set<String> = ["md", "markdown"]
        self.isTextFile = textFileExtensions.contains(url.pathExtension.lowercased())
        self.isMarkdown = markdownExtensions.contains(url.pathExtension.lowercased())
        
        self.children = isFolder ? nil : nil
    }

    func loadChildren() {
        guard isFolder, children == nil else { return }
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: self.url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            self.children = contents.map { FileItemNode(url: $0) }.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } catch {
            self.children = []
        }
    }
}
