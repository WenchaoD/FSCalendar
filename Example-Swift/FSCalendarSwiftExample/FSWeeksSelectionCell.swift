//
//  FSWeeksSelectionCell.swift
//  FSCalendarSwiftExample
//
//  Created by Dipendra Khatri on 8/28/18.
//  Copyright © 2018 wenchao. All rights reserved.
//

import UIKit

protocol FSWeeksSelectionCellDelegate: class {
    func increaseButtonPressed(cell: FSWeeksSelectionCell)
    func decreaseButtonPressed(cell: FSWeeksSelectionCell)
}


class FSWeeksSelectionCell: UITableViewCell {

    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var weeksLabel: UILabel!
    
    weak var delegate: FSWeeksSelectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK:- Target actions
    @IBAction func increaseButtonPressed(sender: AnyObject) {
        delegate?.increaseButtonPressed(cell: self)
    }
    
    @IBAction func decreaseButtonPressed(sender: AnyObject) {
        delegate?.decreaseButtonPressed(cell: self)
    }
}
