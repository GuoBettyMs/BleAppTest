//
//  Alert.swift
//  IOSApp
//
//  Created by gbt on 2022/4/27.
//

import Foundation
import UIKit

class Alert: NSObject {
    
    static func alert(title: String, controllerV: UIViewController) {
        
        let hint = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
        let popover = hint.popoverPresentationController
        if (popover != nil) {
            popover?.sourceView = controllerV.self.view
            popover?.sourceRect = controllerV.self.view.bounds
            popover?.permittedArrowDirections  = .any
        }
        controllerV.present(hint, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            hint.dismiss(animated: true, completion: nil)
        }
        
    }
    
}
