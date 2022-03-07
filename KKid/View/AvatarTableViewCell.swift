//
//  AvatarTableViewCell.swift
//  KKid
//
//  Created by Justin Kumpe on 3/5/22.
//  Copyright © 2022 Justin Kumpe. All rights reserved.
//

import Foundation
import AvatarView

class AvatarTableViewCell: UITableViewCell {

    let avatar: AvatarView = {
        var avatarView: AvatarView!
        avatarView = AvatarView(image: UIImage(named: "plus")!)
        avatarView.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        avatarView.borderColor = UIColor.systemPurple
        avatarView.borderWidth = 2.0
        return avatarView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(avatar)
    }
}
