//
//  ViewController.swift
//  ReadMoreLabel
//
//  Created by Riddhi Khunti on 17/10/24.
//

import UIKit

class AttributedTextVC: UIViewController {

    @IBOutlet weak var lblReadMore: UILabel!
    
    var isExpanded = false
    let readMoreText = "Read More"
    let readLessText = "Read Less"
    var fullText = NSAttributedString()
    
    private func setUpView() {
        applyStyle()
        setupReadMore()
    }

    private func applyStyle() {
        // Adding tap gesture to the label
        fullText = self.lblReadMore.attributedText!
        self.lblReadMore.readMoreTexts = readMoreText
        self.lblReadMore.readLessTexts = readLessText
        lblReadMore.font = UIFont.systemFont(ofSize: 22)
        // -----------------------------------------------------------------------------------------------------------
        //MARK: Extra code when attributed
        // -----------------------------------------------------------------------------------------------------------
        let attributedString = NSMutableAttributedString(attributedString: fullText)
        
        // Define attributes for "Lorem Ipsum"
        let loremIpsumAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red, // Change color
            .font: UIFont.boldSystemFont(ofSize: 18) // Change font
        ]
        
        // Define attributes for "dummy text"
        let dummyTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blue, // Change color
            .font: UIFont.italicSystemFont(ofSize: 18) // Change font
        ]
        
        // Find ranges for "Lorem Ipsum"
        var range = (self.lblReadMore.text! as NSString).range(of: "Lorem Ipsum")
        while range.location != NSNotFound {
            attributedString.addAttributes(loremIpsumAttributes, range: range)
            range = (self.lblReadMore.text! as NSString).range(of: "Lorem Ipsum", options: .literal, range: NSRange(location: range.location + range.length, length: self.lblReadMore.text!.count - range.location - range.length))
        }
        
        // Find ranges for "dummy text"
        range = (self.lblReadMore.text! as NSString).range(of: "dummy text")
        while range.location != NSNotFound {
            attributedString.addAttributes(dummyTextAttributes, range: range)
            range = (self.lblReadMore.text! as NSString).range(of: "dummy text", options: .literal, range: NSRange(location: range.location + range.length, length: self.lblReadMore.text!.count - range.location - range.length))
        }
        // -----------------------------------------------------------------------------------------------------------
        // Set the attributed text to the label
        lblReadMore.attributedText = attributedString
        fullText = self.lblReadMore.attributedText!
        self.lblReadMore.comp = { isSelected in
            self.setupReadMore()
        }
    }
    
    func setupReadMore() {
        if self.lblReadMore.currentNumberOfLines > 4 {
            self.lblReadMore.updateLabel(with: self.lblReadMore.attributedText!, fullText: self.fullText, trailingText: "... ", moreTextFont: UIFont.italicSystemFont(ofSize: 22), moreTextColor: UIColor.red, underlineColor: UIColor.red)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

}
