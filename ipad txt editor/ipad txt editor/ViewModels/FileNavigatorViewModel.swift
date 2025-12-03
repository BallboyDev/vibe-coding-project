//
//  FileNavigatorViewModel.swift
//  ipad txt editor
//
//  Created by ballboy on 12/1/25.
//

import Foundation
import SwiftUI
import Combine // Explicitly import Combine

@MainActor
final class FileNavigatorViewModel: ObservableObject {
    @Published var files: [URL] = []
    
    // State for Alerts
    @Published var isShowingRenameAlert = false
    @Published var isShowingCreateFileAlert = false
    @Published var isShowingCreateDirAlert = false
    
    @Published var itemToEdit: URL? // Also used as the parent directory for creation
    @Published var newName: String = ""
    
    private let fileManager = FileManager.default
    private var documentsURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func loadFiles() {
        guard let url = documentsURL else {
            print("DEBUG: Error: Could not access Documents directory.")
            return
        }
        
        print("DEBUG: Documents URL: \(url.path)") // Debug print
        
        do {
            self.files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            print("DEBUG: Found \(self.files.count) items in Documents directory.") // Debug print
            for fileURL in self.files {
                print("DEBUG: Item: \(fileURL.lastPathComponent)") // Debug print
            }
        } catch {
            print("DEBUG: Error reading contents of Documents directory: \(error.localizedDescription)") // Debug print
        }
    }
    
    func delete(url: URL) {
        do {
            try fileManager.removeItem(at: url)
            loadFiles()
        } catch {
            print("Error deleting item: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Rename Logic
    func promptRename(for url: URL) {
        itemToEdit = url
        newName = url.lastPathComponent
        isShowingRenameAlert = true
    }
    
    func executeRename() {
        guard let oldURL = itemToEdit else { return }
        let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(newName)
        
        do {
            try fileManager.moveItem(at: oldURL, to: newURL)
            loadFiles()
        } catch {
            print("Error renaming item: \(error.localizedDescription)")
        }
        resetInputState()
    }
    
    // MARK: - Create File Logic
    func promptCreateFile(in directory: URL) {
        itemToEdit = directory
        newName = ""
        isShowingCreateFileAlert = true
    }
    
    func executeCreateFile() {
        guard let parentDir = itemToEdit else { return }
        let newURL = parentDir.appendingPathComponent(newName)
        
        guard !newName.isEmpty else { return }
        
        if fileManager.createFile(atPath: newURL.path, contents: Data()) {
            loadFiles()
        } else {
            print("Error creating file.")
        }
        resetInputState()
    }

    // MARK: - Create Directory Logic
    func promptCreateDirectory(in directory: URL) {
        itemToEdit = directory
        newName = ""
        isShowingCreateDirAlert = true
    }
    
    func executeCreateDirectory() {
        guard let parentDir = itemToEdit else { return }
        let newURL = parentDir.appendingPathComponent(newName)
        
        guard !newName.isEmpty else { return }

        do {
            try fileManager.createDirectory(at: newURL, withIntermediateDirectories: false, attributes: nil)
            loadFiles()
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
        resetInputState()
    }
    
    private func resetInputState() {
        isShowingRenameAlert = false
        isShowingCreateFileAlert = false
        isShowingCreateDirAlert = false
        newName = ""
        itemToEdit = nil
    }
}
