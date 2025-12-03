import SwiftUI
import UniformTypeIdentifiers

// MARK: - Main Content View
struct ContentView: View {
    @State private var text: String = "왼쪽 사이드바에서 파일을 선택하거나 폴더를 열어주세요."
    @State private var originalText: String = ""
    @State private var rootNode: FileItemNode?
    @State private var fileNodes: [FileItemNode] = []
    @State private var selectedFile: FileItemNode?
    @State private var isFileImporterPresented = false
    
    @State private var showSaveConfirmAlert: Bool = false
    @State private var pendingNavigationTarget: NavigationTarget?
    
    @State private var showRenameAlert = false
    @State private var itemToRename: FileItemNode?
    @State private var newItemName = ""

    private var isDirty: Bool {
        guard selectedFile != nil else { return false }
        return text != originalText
    }

    enum NavigationTarget { case file(FileItemNode?) }

    var body: some View {
        NavigationSplitView {
            SidebarView(nodes: $fileNodes, selectedFile: $selectedFile, itemToRename: $itemToRename, newItemName: $newItemName, showRenameAlert: $showRenameAlert, onSelect: handleNavigation, onExpand: { $0.loadChildren() })
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isFileImporterPresented = true }) { Label("폴더 열기", systemImage: "folder.badge.plus") }
                }
            }
        } detail: {
            DetailView(text: $text, selectedFile: $selectedFile, isDirty: isDirty, onSave: saveCurrentFile)
        }
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.folder]) { handleFolderSelection(result: $0) }
        .onAppear(perform: loadInitialBookmark)
        .alert("저장하지 않은 변경사항이 있습니다", isPresented: $showSaveConfirmAlert) {
            Button("저장", action: handleAlertSave)
            Button("저장 안 함", role: .destructive, action: handleAlertDontSave)
            Button("취소", role: .cancel) { pendingNavigationTarget = nil }
        } message: { Text("변경사항을 저장하시겠습니까?") }
        .alert("이름 변경", isPresented: $showRenameAlert) {
            TextField("새 이름", text: $newItemName)
            Button("변경", action: renameItem)
            Button("취소", role: .cancel) { }
        } message: {
            Text("새로운 이름을 입력하세요.")
        }
    }
    
    private func handleNavigation(to target: NavigationTarget) {
        if isDirty {
            pendingNavigationTarget = target
            showSaveConfirmAlert = true
        } else {
            proceed(with: target)
        }
    }
    
    private func proceed(with target: NavigationTarget) {
        switch target {
        case .file(let file):
            selectedFile = file
            loadFileContent(fileItem: file)
        }
    }
    
    private func handleAlertSave() {
        saveCurrentFile()
        if let target = pendingNavigationTarget { proceed(with: target) }
        pendingNavigationTarget = nil
    }
    
    private func handleAlertDontSave() {
        if let target = pendingNavigationTarget { proceed(with: target) }
        pendingNavigationTarget = nil
    }

    private func handleFolderSelection(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            rootNode?.url.stopAccessingSecurityScopedResource()
            saveBookmark(for: url)
            guard url.startAccessingSecurityScopedResource() else { return }
            let node = FileItemNode(url: url)
            node.loadChildren()
            self.rootNode = node
            self.fileNodes = [node]
        case .failure(let error): print("폴더 선택 실패: \(error.localizedDescription)")
        }
    }
    
    private func loadFileContent(fileItem: FileItemNode?) {
        guard let fileToLoad = fileItem else {
            text = "파일을 선택해주세요."; originalText = ""; return
        }
        do {
            let loadedText = try String(contentsOf: fileToLoad.url, encoding: .utf8)
            self.text = loadedText; self.originalText = loadedText
        } catch {
            self.text = "파일을 불러올 수 없습니다."; self.originalText = ""
        }
    }
    
    private func saveCurrentFile() {
        guard let fileToSave = selectedFile else { return }
        do {
            try text.write(to: fileToSave.url, atomically: true, encoding: .utf8)
            self.originalText = text
        } catch { print("파일 저장 실패: \(error.localizedDescription)") }
    }
    
    private func renameItem() {
        // 항상 최상위 폴더의 권한을 사용해야 함
        guard let rootURL = rootNode?.url, rootURL.startAccessingSecurityScopedResource() else {
            print("루트 폴더 접근 권한 획득 실패")
            return
        }
        defer { rootURL.stopAccessingSecurityScopedResource() }

        guard let itemToRename = itemToRename else { return }
        guard !newItemName.isEmpty, newItemName != itemToRename.name else { return }
        
        let newURL = itemToRename.url.deletingLastPathComponent().appendingPathComponent(newItemName)
        
        do {
            try FileManager.default.moveItem(at: itemToRename.url, to: newURL)
            itemToRename.name = newItemName
            itemToRename.url = newURL
        } catch {
            print("이름 변경 실패: \(error.localizedDescription)")
        }
    }
    
    private func saveBookmark(for url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        do {
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: "folderBookmark")
        } catch { print("북마크 저장 실패: \(error.localizedDescription)") }
    }
    
    private func loadInitialBookmark() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "folderBookmark") else { return }
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            let node = FileItemNode(url: url)
            node.loadChildren()
            self.rootNode = node
            self.fileNodes = [node]
        } catch { print("북마크 로딩 실패: \(error.localizedDescription)") }
    }
}
