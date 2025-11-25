//
//  Extension+UIViewController.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/25/25.
//

import SwiftUI

// TODO: SwiftUI-Introspect 사용하면 CategoryMainView에서 findNavigationController() 안써도 됨
extension UIViewController {
    func findNavigationController() -> UINavigationController? {
        if let navigationController = self as? UINavigationController {
            return navigationController
        }
        
        for child in children {
            if let navigationController = child.findNavigationController() {
                return navigationController
            }
        }
        
        return nil
    }
}
