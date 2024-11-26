//
//  TableViewCell.swift
//  ReadMoreLabel
//
//  Created by Riddhi Khunti on 23/10/24.
//

import UIKit


class TableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    
    let readMoreText = "Read More"
    let readLessText = "Read Less"
    var fullText = NSAttributedString()
    
    private func setupReadMore() {
        if self.lblTitle.currentNumberOfLines > 4 {
            self.lblTitle.updateLabel(with: self.lblTitle.attributedText!, fullText: self.fullText, trailingText: "... ", moreTextFont: UIFont.italicSystemFont(ofSize: 22), moreTextColor: .red, underlineColor: .red)
        }
        UIView.animate(withDuration: 0.3) {
            if let tableView = self.superview as? UITableView {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fullText = self.lblTitle.attributedText!
        self.lblTitle.readMoreTexts = readMoreText
        self.lblTitle.readLessTexts = readLessText
        lblTitle.font = UIFont.systemFont(ofSize: 22)
        // Set the attributed text to the label
        lblTitle.attributedText = NSMutableAttributedString(attributedString: fullText)
        fullText = self.lblTitle.attributedText!
        setupReadMore()
        self.lblTitle.comp = { isSelected in
            self.setupReadMore()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
