//
//  StatusBarView.swift
//  ipad txt editor
//
//  Created by ballboy on 12/1/25.
//

import SwiftUI

struct StatusBarView: View {
    let file: URL?

    var body: some View {
        HStack {
            if file != nil {
                Text(fileExtension)
                Spacer()
                Text(fileSize)
            } else {
                Text("No file selected")
                Spacer()
            }
        }
        .padding(.horizontal)
        .frame(height: 22)
        .background(Color.black.opacity(0.2))
    }
    
    private var fileExtension: String {
        file?.pathExtension.uppercased() ?? "TXT"
    }
    
    private var fileSize: String {
        guard let url = file else { return "-- KB" }
        do {
            let resources = try url.resourceValues(forKeys: [.fileSizeKey])
            let fileSize = resources.fileSize ?? 0
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: Int64(fileSize))
        } catch {
            return "-- KB"
        }
    }
}

#Preview {
    StatusBarView(file: URL(string: "file:///Users/ballboy/Documents/MyFile.md"))
}
