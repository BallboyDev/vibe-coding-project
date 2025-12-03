import SwiftUI

// MARK: - Markdown Editor
struct MarkdownEditorView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 16)
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            let selectedRange = uiView.selectedRange
            uiView.attributedText = context.coordinator.applyMarkdownHighlighting(to: text)
            uiView.selectedRange = selectedRange
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownEditorView

        init(_ parent: MarkdownEditorView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            if parent.text != textView.text {
                parent.text = textView.text
            }
            
            let selectedRange = textView.selectedRange
            let visibleRect = textView.bounds
            
            textView.attributedText = applyMarkdownHighlighting(to: textView.text)
            
            textView.selectedRange = selectedRange
            textView.scrollRectToVisible(visibleRect, animated: false)
        }
        
        func applyMarkdownHighlighting(to text: String) -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: text)
            let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)

            // Base style
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: fullRange)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: fullRange)

            // Regex patterns
            let patterns: [String: [NSAttributedString.Key: Any]] = [
                // Headers (#)
                "^#+\\s.*$": [NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)],
                // Bold (**...**)
                "\\*\\*(.*?)\\*\\*": [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)],
                // Italic (*...*)
                "(?<!\\*)\\(?!\\*)(.*?)(?<!\\*)\\(?!\\*)": [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 16)],
                // Inline code (`...`)
                "`([`]+)`": [NSAttributedString.Key.backgroundColor: UIColor.secondarySystemBackground, NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)]
            ]

            for (pattern, attributes) in patterns {
                guard let regex = try? NSRegularExpression(pattern: pattern, options: pattern == "^#+\\s.*$" ? .anchorsMatchLines : []) else {
                    continue
                }
                
                regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                    guard let matchRange = match?.range else { return }
                    attributedString.addAttributes(attributes, range: matchRange)
                }
            }

            return attributedString
        }
    }
}