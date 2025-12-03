import SwiftUI

// MARK: - Sidebar Views
struct SidebarView: View {
    @Binding var nodes: [FileItemNode]
    @Binding var selectedFile: FileItemNode?
    
    // ContentView의 상태를 직접 제어하기 위한 바인딩
    @Binding var itemToRename: FileItemNode?
    @Binding var newItemName: String
    @Binding var showRenameAlert: Bool
    
    var onSelect: (ContentView.NavigationTarget) -> Void
    var onExpand: (FileItemNode) -> Void

    var body: some View {
        List {
            ForEach(nodes) { node in
                FileNodeView(node: node, selectedFile: $selectedFile, itemToRename: $itemToRename, newItemName: $newItemName, showRenameAlert: $showRenameAlert, onSelect: onSelect, onExpand: onExpand)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(nodes.first?.name ?? "파일")
    }
}

struct FileNodeView: View {
    @ObservedObject var node: FileItemNode
    @Binding var selectedFile: FileItemNode?
    
    // ContentView의 상태를 직접 제어하기 위한 바인딩
    @Binding var itemToRename: FileItemNode?
    @Binding var newItemName: String
    @Binding var showRenameAlert: Bool
    
    var onSelect: (ContentView.NavigationTarget) -> Void
    var onExpand: (FileItemNode) -> Void

    var body: some View {
        if node.isFolder {
            DisclosureGroup(isExpanded: $node.isExpanded) {
                if let children = node.children {
                    ForEach(children) { childNode in
                        FileNodeView(node: childNode, selectedFile: $selectedFile, itemToRename: $itemToRename, newItemName: $newItemName, showRenameAlert: $showRenameAlert, onSelect: onSelect, onExpand: onExpand).padding(.leading, 12)
                    }
                }
            } label: {
                Label(node.name, systemImage: "folder.fill")
                    .onTapGesture { node.isExpanded.toggle() }
            }
            .contextMenu { 
                Button(action: { 
                    // 클로저 대신, 바인딩된 상태를 직접 변경
                    itemToRename = node
                    newItemName = node.name
                    showRenameAlert = true
                }) {
                    Label("이름 변경", systemImage: "pencil")
                }
            }
            .onChange(of: node.isExpanded) { _, isExpanded in if isExpanded { onExpand(node) } }
        } else {
            let label = Label(node.name, systemImage: node.isTextFile ? "doc.text" : "doc.questionmark")
            
            if node.isTextFile {
                label
                    .background(node.id == selectedFile?.id ? Color.accentColor.opacity(0.3) : Color.clear)
                    .onTapGesture { onSelect(.file(node)) }
                    .contextMenu { 
                        Button(action: { 
                            // 클로저 대신, 바인딩된 상태를 직접 변경
                            itemToRename = node
                            newItemName = node.name
                            showRenameAlert = true
                        }) {
                            Label("이름 변경", systemImage: "pencil")
                        }
                    }
            } else {
                label.foregroundStyle(.secondary)
            }
        }
    }
}
