//
//  StoryboardInstantiable.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/11/15.
//  Copyright © 2017年 touyou. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable: class {
    
    static var storyboardName: String { get }
}

extension StoryboardInstantiable where Self: UIViewController {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
    
    static func instantiate() -> Self {
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        guard let controller = storyboard.instantiateInitialViewController() as? Self else {
          
            assert(false, "生成したいViewControllerと同じ名前のStorybaordが見つからないか、Initial ViewControllerに設定されていない可能性があります。")
            fatalError()
        }
        
        return controller
    }
}
