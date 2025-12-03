//
//  FileNavigatorView.swift
//  ipad txt editor
//
//  Created by ballboy on 12/1/25.
//

import SwiftUI

struct FileNavigatorView: View {
    @StateObject private var viewModel = FileNavigatorViewModel()
    @EnvironmentObject var editorManager: EditorManager

    var body: some View {
        List(viewModel.files, id: \.self) { url in
            Button(action: {
                editorManager.openFile(url: url)
            }) {
                HStack {
                    Image(systemName: url.hasDirectoryPath ? "folder" : "doc.text")
                    Text(url.lastPathComponent)
                }
            }
            .contextMenu {
                if url.hasDirectoryPath {
                    Button("New Directory", action: { viewModel.promptCreateDirectory(in: url) })
                    Button("New File", action: { viewModel.promptCreateFile(in: url) })
                    Button("Rename", action: { viewModel.promptRename(for: url) })
                    Button("Delete", role: .destructive, action: { viewModel.delete(url: url) })
                } else {
                    Button("Rename", action: { viewModel.promptRename(for: url) })
                    Button("Delete", role: .destructive, action: { viewModel.delete(url: url) })
                }
            }
        }
        .navigationTitle("Files")
        .onAppear {
            viewModel.loadFiles()
        }
        .alert("Rename", isPresented: $viewModel.isShowingRenameAlert) {
            TextField("New Name", text: $viewModel.newName)
            Button("Rename", action: viewModel.executeRename)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a new name for \(viewModel.itemToEdit?.lastPathComponent ?? "the item").")
        }
        .alert("New File", isPresented: $viewModel.isShowingCreateFileAlert) {
            TextField("Filename", text: $viewModel.newName)
            Button("Create", action: viewModel.executeCreateFile)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a name for the new file.")
        }
        .alert("New Directory", isPresented: $viewModel.isShowingCreateDirAlert) {
            TextField("Directory Name", text: $viewModel.newName)
            Button("Create", action: viewModel.executeCreateDirectory)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a name for the new directory.")
        }
    }
}

#Preview {
    FileNavigatorView()
        .environmentObject(EditorManager())
}
