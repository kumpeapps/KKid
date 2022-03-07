//
//  ModuleCollectionViewCell.swift
//  KKid
//
//  Created by Justin Kumpe on 10/5/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import BadgeSwift
import AvatarView

class ModuleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var badge: BadgeSwift!
}
