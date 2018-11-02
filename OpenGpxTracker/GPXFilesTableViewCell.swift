//
//  GPXFilesTableViewCell.swift
//  OpenGpxTracker
//
//  Created by Vincent on 25/10/18.
//  Copyright © 2018 TransitBox. All rights reserved.
//

import UIKit

class GPXFilesTableViewCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let lastModifiedLabel = UILabel()
    let distanceLabel = UILabel()
    let locationLabel = UILabel()
    let timeElapsedLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let viewWidth = self.frame.width - 16 // minusing off left margin
        let titleFont = UIFont.systemFont(ofSize: 18) // larger title
        let subtitleFont = UIFont.systemFont(ofSize: 12) // smaller subtitle
        
        nameLabel.frame = CGRect(x: 16, y: 5, width: viewWidth, height: 35)
        nameLabel.font = titleFont
        contentView.addSubview(nameLabel)
        
        lastModifiedLabel.frame = CGRect(x: 16, y: 40, width: viewWidth, height: 20)
        lastModifiedLabel.font = subtitleFont
        contentView.addSubview(lastModifiedLabel)
        
        distanceLabel.frame = CGRect(x: 16, y: 60, width: viewWidth, height: 20)
        distanceLabel.font = subtitleFont
        contentView.addSubview(distanceLabel)
        
        locationLabel.frame = CGRect(x: 16, y: 80, width: viewWidth, height: 20)
        locationLabel.font = subtitleFont
        contentView.addSubview(locationLabel)
        
        timeElapsedLabel.frame = CGRect(x: 16, y: 100, width: viewWidth, height: 20)
        timeElapsedLabel.font = subtitleFont
        contentView.addSubview(timeElapsedLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
