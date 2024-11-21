//
//  NormalTextVC.swift
//  ReadMoreLabel
//
//  Created by Riddhi Khunti on 23/10/24.
//

import Foundation
import UIKit

class NormalTextVC: UIViewController {
    
    @IBOutlet weak var lblReadMore: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    
    let readMoreText = "Read More"
    let readLessText = "Read Less"
    var fullText = NSAttributedString()
    
    private func setUpView() {
        applyStyle()
    }
    
    private func applyStyle() {
        // Adding tap gesture to the label
        fullText = self.lblReadMore.attributedText!
        self.lblReadMore.readMoreTexts = readMoreText
        self.lblReadMore.readLessTexts = readLessText
        lblReadMore.font = UIFont.systemFont(ofSize: 22)
        // Set the attributed text to the label
        lblReadMore.attributedText = NSMutableAttributedString(attributedString: fullText)
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
        setupReadMore()
    }
    
}
