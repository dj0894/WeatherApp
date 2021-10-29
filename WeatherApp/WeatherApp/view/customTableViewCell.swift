//
//  customTableViewCell.swift
//  WeatherApp
//
//  Created by Deepika Jha on 29/10/21.
//

import UIKit

class customTableViewCell: UITableViewCell {

   
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var imageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
