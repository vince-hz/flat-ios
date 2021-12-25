//
//  RoomTableViewCell.swift
//  Flat
//
//  Created by xuyunshi on 2021/10/19.
//  Copyright © 2021 agora.io. All rights reserved.
//


import UIKit

class RoomTableViewCell: UITableViewCell {
    @IBOutlet weak var roomTimeLabel: UILabel!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mainTextView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorLineHeightConstraint.constant = 1 / UIScreen.main.scale
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.mainTextView.layer.backgroundColor = selected ?  UIColor.controlSelectedBG.cgColor : UIColor.whiteBG.cgColor
            }
        } else {
            mainTextView.backgroundColor = selected ?  .controlSelectedBG : .whiteBG
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if animated {
            mainTextView.layer.backgroundColor = highlighted ?  UIColor.controlSelectedBG.cgColor : UIColor.whiteBG.cgColor
        } else {
            mainTextView.backgroundColor = highlighted ?  .controlSelectedBG : .whiteBG
        }
    }
    
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!
}