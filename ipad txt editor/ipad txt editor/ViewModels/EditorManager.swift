//
//  EditorManager.swift
//  ipad txt editor
//
//  Created by ballboy on 12/1/25.
//

import Foundation
import SwiftUI
import Combine // Explicitly import Combine

@MainActor
final class EditorManager: ObservableObject {
    @Published var fileContent: String
    @Published var currentFile: URL?
    
    init() {
        self.fileContent = "Select a file to begin."
        self.currentFile = nil
    }
    
    func openFile(url: URL) {
        // We only handle files, not directories
        guard !url.hasDirectoryPath else { return }
        
        do {
            self.fileContent = try String(contentsOf: url, encoding: .utf8)
            self.currentFile = url
        } catch {
            self.fileContent = "Error reading file: \(error.localizedDescription)"
            self.currentFile = nil
        }
    }
    
    func saveFile() {
        guard let url = currentFile else {
            // In a real app, you might want to present a 'Save As' dialog
            print("Error: No file is currently open.")
            return
        }
        
        do {
            try fileContent.write(to: url, atomically: true, encoding: .utf8)
            print("File saved successfully.")
        } catch {
            // In a real app, handle this error with an alert to the user
            print("Error saving file: \(error.localizedDescription)")
        }
    }
}
