//
//  EditorView.swift
//  ipad txt editor
//
//  Created by ballboy on 12/1/25.
//

import SwiftUI
import CodeEditor

struct EditorView: View {
    @Binding var text: String

    var body: some View {
        CodeEditor(source: $text, language: .markdown, theme: .ocean)
    }
}

#Preview {
    EditorView(text: .constant("# Hello, World!\n\nThis is a preview."))
}
