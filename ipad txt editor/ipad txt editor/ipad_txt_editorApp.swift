//
//  ipad_txt_editorApp.swift
//  ipad txt editor
//
//  Created by ballboy on 12/1/25.
//

import SwiftUI

@main
struct ipad_txt_editorApp: App {
    @StateObject private var editorManager = EditorManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(editorManager)
        }
    }
}
