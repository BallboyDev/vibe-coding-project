//
//  ContentView.swift
//  ipad txt editor
//
//  Created by ballboy on 12/1/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var editorManager: EditorManager

    var body: some View {
        NavigationSplitView {
            FileNavigatorView()
        } detail: {
            VStack(spacing: 0) {
                TopInfoBarView(file: editorManager.currentFile)
                
                EditorView(text: $editorManager.fileContent)
                
                StatusBarView(file: editorManager.currentFile)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        editorManager.saveFile()
                    }) {
                        Image(systemName: "square.and.arrow.down") // Changed from Label to Image
                    }
                    .keyboardShortcut("s", modifiers: .command)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environmentObject(EditorManager())
}
