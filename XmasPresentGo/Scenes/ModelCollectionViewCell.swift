//
//  ModelCollectionViewCell.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/12/07.
//  Copyright © 2017年 touyou. All rights reserved.
//

import UIKit
import SceneKit

class ModelCollectionViewCell: UICollectionViewCell, NibLoadable, Reusable {
    
    @IBOutlet weak var modelView: SCNView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
