//
//  WKWebView.swift
//  IOSApp
//
//  Created by gbt on 2022/7/20.
//

import UIKit
import WebKit

extension WKWebView{
    func load(string: String){
        if let url = URL(string: string){
            load(URLRequest(url: url))
        }
    }
}
