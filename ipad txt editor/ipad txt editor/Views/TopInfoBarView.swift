//
//  TopInfoBarView.swift
//  ipad txt editor
//
//  Created by ballboy on 12/1/25.
//

import SwiftUI

struct TopInfoBarView: View {
    let file: URL?

    var body: some View {
        HStack {
            Text(file?.lastPathComponent ?? "No File Selected")
                .padding(.horizontal)
            Spacer()
        }
        .frame(height: 35)
        .background(Color.black.opacity(0.1))
    }
}

#Preview {
    TopInfoBarView(file: URL(string: "file:///Users/ballboy/Documents/MyFile.md"))
}
