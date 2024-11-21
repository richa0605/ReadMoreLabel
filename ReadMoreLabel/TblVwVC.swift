//
//  TblVwVC.swift
//  ReadMoreLabel
//
//  Created by Riddhi Khunti on 23/10/24.
//

import Foundation
import UIKit

class TblVwVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the XIB file
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TableViewCell")

        // Set the table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
    }
}
extension TblVwVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20 // Return the number of rows you want
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        return cell
    }
}
