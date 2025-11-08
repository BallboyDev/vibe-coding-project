import SwiftUI

// MARK: - Detail View
struct DetailView: View {
    @Binding var text: String
    @Binding var selectedFile: FileItemNode?
    let isDirty: Bool
    var onSave: () -> Void

    var body: some View {
        Group {
            if let file = selectedFile {
                if file.isMarkdown {
                    MarkdownEditorView(text: $text)
                } else {
                    TextEditor(text: $text)
                }
            } else {
                Text("파일을 선택해주세요.")
            }
        }
        .navigationTitle(selectedFile?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if selectedFile != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button("저장", systemImage: "doc.text.fill", action: onSave)
                        .disabled(!isDirty)
                        .keyboardShortcut("s", modifiers: .command)
                }
            }
        }
    }
}
