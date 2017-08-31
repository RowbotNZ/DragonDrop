//
//  PerfectCell.swift
//  DragonDrop
//
//  Created by Rowan on 19/08/17.
//  Copyright © 2017 Rowan Livingstone. All rights reserved.
//

import Foundation
import UIKit

class PerfectCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        activityIndicator.stopAnimating()
        titleLabel.text = nil
        detailLabel.text = nil
    }
    
}
