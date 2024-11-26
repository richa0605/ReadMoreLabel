//
//  UILabelCode.swift
//  ReadMoreLabel
//
//  Created by Riddhi Khunti on 17/10/24.
//

import Foundation
import UIKit
import ObjectiveC

private var UILabelIsExpandedKey: UInt8 = 0
private var UILabelReadMoreKey: UInt8 = 0
private var UILabelReadLessKey: UInt8 = 0
private var compKey: UInt8 = 0

extension UILabel {
    var isExpanded: Bool {
        get {
            return objc_getAssociatedObject(self, &UILabelIsExpandedKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UILabelIsExpandedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UILabel {
    var readMoreTexts: String {
        get {
            return objc_getAssociatedObject(self, &UILabelReadMoreKey) as? String ?? "Read More"
        }
        set {
            objc_setAssociatedObject(self, &UILabelReadMoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UILabel {
    var readLessTexts: String {
        get {
            return objc_getAssociatedObject(self, &UILabelReadLessKey) as? String ?? "Read Less"
        }
        set {
            objc_setAssociatedObject(self, &UILabelReadLessKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UILabel {
    var comp: ((Bool) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &compKey) as? ((Bool) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &compKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UILabel {
    var currentNumberOfLines: Int {
        let size = CGSize(width: self.frame.width, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let attributes: [NSAttributedString.Key: Any] = [.font: self.font!]
        
        // Calculate the bounding rect for the label's text
        let boundingRect = self.text?.boundingRect(with: size,
                                                   options: options,
                                                   attributes: attributes,
                                                   context: nil) ?? .zero
        
        // Calculate the height of a single line of text
        let lineHeight = self.font.lineHeight
        
        // Calculate the number of lines based on the bounding rect height
        return Int(ceil(boundingRect.height / lineHeight))
    }
}

extension UILabel {
    
    func addTrailing(text: NSAttributedString = NSAttributedString(), with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor, underlineColor: UIColor = .clear) {
        let answerAttributed = NSMutableAttributedString()
        answerAttributed.append(text)
        answerAttributed.append(NSMutableAttributedString(string: trailingText, attributes: [NSAttributedString.Key.font: self.font!]))
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.underlineColor: underlineColor, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
        self.addTapGestureToMoreText()
        self.numberOfLines = 0
    }
    
    func updateLabel(with text: NSAttributedString, fullText: NSAttributedString, trailingText: String, moreTextFont: UIFont, moreTextColor: UIColor, underlineColor: UIColor = .clear, maxLines: Int = 5) {
        if isExpanded {
            // If expanded, show full text with "Read Less"
            addTrailing(text: fullText, with: " ", moreText: self.readLessTexts, moreTextFont: moreTextFont, moreTextColor: moreTextColor, underlineColor: underlineColor)
        } else {
            if let fifthLineText = getTextUpToMaxLine(fullText: text, maxLines: maxLines) {
                let truncatedText = removeLastCharactersAndAddReadMore(from: fifthLineText, count: self.readMoreTexts.count, moreText: self.readMoreTexts)
                addTrailing(text: truncatedText, with: trailingText, moreText: self.readMoreTexts, moreTextFont: moreTextFont, moreTextColor: moreTextColor, underlineColor: underlineColor)
            }
        }
        
    }
    
    private func getMaxLineText(fullText: String, maxLines: Int) -> String? {
        // Create a temporary UILabel to measure the text
        let tempLabel = UILabel()
        tempLabel.font = self.font // Set the font to match the original label
        tempLabel.numberOfLines = 0 // Allow for multiple lines
        
        // Break the text into lines based on the label's width
        var lines: [String] = []
        let textSize = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let textAttributes: [NSAttributedString.Key: Any] = [.font: tempLabel.font as Any]
        
        var currentLine = ""
        
        for word in fullText.split(separator: " ") {
            let testLine = currentLine.isEmpty ? "\(word)" : "\(currentLine) \(word)"
            let size = (testLine as NSString).size(withAttributes: textAttributes)
            
            if size.width <= textSize.width {
                currentLine = testLine
            } else {
                lines.append(currentLine)
                currentLine = "\(word)" // Start new line with the current word
            }
        }
        
        // Append the last line if it's not empty
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        // Check if we have at least 5 lines
        if lines.count >= maxLines {
            return lines[maxLines - 1] // Return the 5th line (index 4)
        }
        
        return nil // Less than 5 lines available
        
    }
    
    private func getTextUpToMaxLine(fullText: NSAttributedString, maxLines: Int) -> NSAttributedString? {
        // Create a temporary UILabel to measure the text
        let tempLabel = UILabel()
        tempLabel.font = self.font // Set the font to match the original label
        tempLabel.numberOfLines = 0 // Allow for multiple lines
        
        // Break the text into lines based on the label's width
        var lines: [NSAttributedString] = []
        let textSize = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        
        var currentLine = NSMutableAttributedString() // Use NSMutableAttributedString to build the result
        
        // Iterate through the words in the attributed string
        let words = fullText.string.split(separator: " ")
        var currentIndex = 0
        
        for word in words {
            // Get the range of the current word in the full text
            let wordRange = (fullText.string as NSString).range(of: String(word), options: .literal, range: NSRange(location: currentIndex, length: fullText.length - currentIndex))
            
            // Create a new attributed string for the word with its original attributes
            let wordAttributes = fullText.attributes(at: wordRange.location, effectiveRange: nil)
            let wordString = NSAttributedString(string: " \(word)", attributes: wordAttributes)
            
            // Create a test attributed string to check its width
            let testAttributedString = NSMutableAttributedString(attributedString: currentLine)
            testAttributedString.append(wordString)
            
            let size = testAttributedString.size()
            
            if size.width <= textSize.width {
                // If the new line fits, update the current line
                currentLine.append(wordString)
            } else {
                // If it doesn't fit, save the current line and start a new one
                lines.append(currentLine)
                currentLine = NSMutableAttributedString(attributedString: wordString) // Start new line with the current word
            }
            
            currentIndex += wordRange.length // Move to the next word index
        }
        
        // Append the last line if it's not empty
        if currentLine.length > 0 {
            lines.append(currentLine)
        }
        
        // Get only up to maxLines and create a new attributed string
        let linesToShow = Array(lines.prefix(maxLines))
        let resultAttributedString = NSMutableAttributedString()
        
        for line in linesToShow {
            resultAttributedString.append(line)
            resultAttributedString.append(NSAttributedString(string: "\n")) // Append a newline character for each line
        }
        
        // Remove the last newline character if present
        if resultAttributedString.length > 0 {
            resultAttributedString.deleteCharacters(in: NSRange(location: resultAttributedString.length - 1, length: 1))
        }
        
        return resultAttributedString
    }
    
    private func removeLastCharactersAndAddReadMore(from text: NSAttributedString, count: Int, moreText: String) -> NSAttributedString {
        // Ensure we don't attempt to remove more characters than the string contains
        guard count < text.string.count else {
            // Return only "Read More" with attributes if count is greater or equal to the text length
            return NSAttributedString(string: moreText) // Ensure this has any desired attributes
        }
        
        // Remove the last 'count' characters from the text
        let index = text.string.index(text.string.endIndex, offsetBy: -count)
        let trimmedText = String(text.string[..<index])
        
        // Create a new attributed string for the trimmed text
        let trimmedAttributedString = NSMutableAttributedString(string: trimmedText)
        
        // Apply attributes from the original text to the trimmed string
        for (i, char) in trimmedText.enumerated() {
            let characterRange = NSRange(location: i, length: 1)
            // Get the original index of the character in the full text
            let originalIndex = text.string.index(text.string.startIndex, offsetBy: i)
            
            // Get the attributes for the original character
            let attributes = text.attributes(at: text.string.distance(from: text.string.startIndex, to: originalIndex), effectiveRange: nil)
            
            // Add attributes to the trimmed attributed string
            trimmedAttributedString.addAttributes(attributes, range: characterRange)
        }
        
        return trimmedAttributedString
    }
    
    func getIndexOfTappedCharacter(at point: CGPoint) -> Int? {
        guard let attributedText = self.attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        // Use the label's size but adjust for any potential insets
        let textContainer = NSTextContainer(size: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0 // Remove padding for accurate hit testing
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        // Convert the point to the correct character index
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: nil)
        
        // Check if the glyph index is valid
        if glyphIndex >= layoutManager.numberOfGlyphs {
            return nil
        }
        
        return layoutManager.characterIndexForGlyph(at: glyphIndex)
    }
    
}


extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        
        // Create instances of NSLayoutManager, NSTextContainer, and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = label.bounds.size
        
        // Get the location of the touch in the label
        let locationOfTouchInLabel = self.location(in: label)
        
        // Find the bounding box for the text inside the label
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        // Adjust the touch location by taking text alignment into account
        let textContainerOffset = CGPoint(
            x: (label.bounds.size.width - textBoundingBox.size.width) - textBoundingBox.origin.x,
            y: (label.bounds.size.height - textBoundingBox.size.height) * 0.98 - textBoundingBox.origin.y
        )
        
        // Calculate the location of the touch within the text container
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        
        // Get the character index for the tapped location
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Calculate the range of the target text (e.g., "Read Less")
        let fullString = attributedText.string
        
        
        // Check if the tapped index is within the target range
        if targetRange.toOptionalRange()?.contains(indexOfCharacter) == true {
            print("Tapped on 'Read Less'")
            return true // Target text was tapped
        }
        
        return false // No relevant text was tapped
    }
    
    
    
}

extension UILabel {
    // Add tap gesture recognizer to the "Read More" or "Read Less" text
    func addTapGestureToMoreText() {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnMoreText(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapOnMoreText(_ recognizer: UITapGestureRecognizer) {
        guard let attributedText = self.attributedText else { return }
        
        // Define ranges for "Read More" and "Read Less" texts
        let lastMoreTextRange = (self.text! as NSString).range(of: self.readMoreTexts, options: .backwards) // Get the last occurrence
        let lessTextRange = (self.text! as NSString).range(of: self.readLessTexts, options: .backwards)
        
        let tapLocation = recognizer.location(in: self)
        let tapIndex = getIndexOfTappedCharacter(at: tapLocation)
        
        if let tapIndex = tapIndex {
            // Check if the tap is in the last "Read More" range
            if NSLocationInRange(tapIndex, lastMoreTextRange) && lastMoreTextRange.location != NSNotFound {
                print("Tapped on last Read More")
                if !isExpanded {
                    isExpanded = true
                    print("Tapped on \(isExpanded)")
                    comp?(true)
                }
                return // Exit after handling this tap
            }
            // Check if the tap is in the "Read Less" range
            //            if recognizer.didTapAttributedTextInLabel(label: self , inRange: self.readLessTexts) {
            if let range = rangeOfLast9Characters() {
                if recognizer.didTapAttributedTextInLabel(label: self, inRange: range) {
                    print("Tapped on the last 9 characters")
                    // Handle your action here, e.g., toggle expanded state or show a label
                    if isExpanded {
                        isExpanded = false
                        print("Tapped on Read Less")
                        comp?(false)
                    }
                }
            }
        }
    }
    
    private func rangeOfLast9Characters() -> NSRange? {
        guard let text = self.text, text.count > 9 else {
            return nil  // Return nil if the text is less than 9 characters
        }
        
        // Get the range of the last 9 characters in the string
        let startIndex = text.index(text.endIndex, offsetBy: -9)
        let substring = String(text[startIndex..<text.endIndex])
        
        // Get the NSRange of the last 9 characters
        let range = (text as NSString).range(of: substring)
        
        // If range is valid, return it
        if range.location != NSNotFound {
            return range
        }
        
        return nil  // Return nil if the range is not found
    }
    
}

//MARK:- Screen resolution
struct ScreenSize {
    static var heightAspectRatio: CGFloat {
        return UIScreen.main.bounds.size.height / 844
    }
}
extension NSRange {
    func toOptionalRange() -> Range<Int>? {
        guard location != NSNotFound else { return nil }
        return location..<location+length
    }
}
