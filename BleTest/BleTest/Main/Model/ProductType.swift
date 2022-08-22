//
//  ProductType.swift
//  ISD Link
//
//  Created by isdt on 2021/6/24.
//
import UIKit
import Foundation

enum ProductType {
    case Null
    case K4
    case X16
    case P30
    case Air8
    case NP2Air
    case LP2Air
    case C4Air
    case Power200
    case K2Air
    case B80
}

class ProductImg{
    
    func titleImg(_ string: String) -> UIImage {
        
        var image = UIImage(named: "1")
        switch string {
        case "calculator":
            image = UIImage(named: "Calculator")
        case "emittertest":
            image = UIImage(named: "Emittercell")
        case "aAInfographics":
            image = UIImage(named: "Chart")
        case "testCollection":
            image = UIImage(named: "Collection")
        case "testBluetooth":
            image = UIImage(named: "testBluetooth")
        case "bleCentral":
            image = UIImage(named: "blePeripheral")
        case "blePeripheral":
            image = UIImage(named: "blePeripheral")
        case "jsonPasing":
            image = UIImage(named: "jsonPasing")
        case "MenuTable":
            image = UIImage(named: "menuTable")
        case "RecordBook":
            image = UIImage(named: "book")
        case "WKWebView":
            image = UIImage(named: "web")
        default:
            image = UIImage(named: "1")
        }
        return image ?? UIImage(named: "1")!
    }
}

struct Product {
    
    
    static let Null = "Null"
    static let K4 = "K4"
    static let X16 = "X16"
    static let Air8 = "Air8"
    static let NP2Air = "NP2Air"
    static let LP2Air = "LP2Air"
    static let C4Air = "C4Air"
    static let Power200 = "Power200"
    static let K2Air = "K2Air"
    static let B80 = "B80"
    

    
    static let TYPE_NAME = [
        
        ProductType.Null : "Null",
        ProductType.K4 : "K4",
        ProductType.X16 : "X16",
        ProductType.Air8 : "Air8",
        ProductType.NP2Air : "NP2Air",
        ProductType.LP2Air : "LP2Air",
        ProductType.C4Air : "C4Air",
        ProductType.Power200 : "Power200",
        ProductType.K2Air : "K2Air",
        ProductType.B80 : "B80",


    ]
    
    static let NAME = [
        
        ProductType.Null : "Null",
        ProductType.K4 : "K4",
        ProductType.X16 : "X16",
        ProductType.Air8 : "Air8",
        ProductType.NP2Air : "NP2 Air",
        ProductType.LP2Air : "LP2 Air",
        ProductType.C4Air : "C4 Air",
        ProductType.Power200 : "Power 200",
        ProductType.K2Air : "K2 Air",
        ProductType.B80 : "B80",
        
        
    ]

    
    static let LOGO = [
        
        ProductType.K4 : UIImage(named: "K4Icon"),
        ProductType.X16 : UIImage(named: "X16Icon"),
        ProductType.Air8 : UIImage(named: "Air8Icon"),
        ProductType.NP2Air : UIImage(named: "NP2AirIcon"),
        ProductType.LP2Air : UIImage(named: "LP2AirIcon"),
        ProductType.C4Air : UIImage(named: "C4AirIcon"),
        ProductType.Power200 : UIImage(named: "Power200Icon"),
        ProductType.K2Air : UIImage(named: "C4AirIcon"),
        ProductType.B80 : UIImage(named: "C4AirIcon")


    ]
    
    static let SCANLOGO = [
        
        ProductType.K4 : UIImage(named: "Scan-K4"),
        ProductType.X16 : UIImage(named: "Scan-X16"),
        ProductType.Air8 : UIImage(named: "Scan-Air8"),
        ProductType.NP2Air : UIImage(named: "Scan-NP2Air"),
        ProductType.LP2Air : UIImage(named: "Scan-LP2Air"),
        ProductType.C4Air : UIImage(named: "Scan-C4Air"),
        ProductType.Power200 : UIImage(named: "Scan-Power200"),
        ProductType.K2Air : UIImage(named: "Scan-K2Air"),
        ProductType.B80 : UIImage(named: "Scan-C4Air")

    ]
    
    static let SCANHINT = [
        
        ProductType.K4 : NSLocalizedString("AddHint", comment: "AddHint"),
        ProductType.X16 : NSLocalizedString("AddHint", comment: "AddHint"),
        ProductType.Air8 : NSLocalizedString("AddHint", comment: "AddHint"),
        ProductType.NP2Air : NSLocalizedString("C4NP2LP2AddHint", comment: "C4NP2LP2AddHint"),
        ProductType.LP2Air : NSLocalizedString("C4NP2LP2AddHint", comment: "C4NP2LP2AddHint"),
        ProductType.C4Air : NSLocalizedString("C4NP2LP2AddHint", comment: "C4NP2LP2AddHint"),
        ProductType.Power200 : NSLocalizedString("Power200AddHint", comment: "Power200AddHint"),
        ProductType.K2Air : NSLocalizedString("AddHint", comment: "AddHint"),
        ProductType.B80 : NSLocalizedString("AddHint", comment: "AddHint")

    ]
    
    static let SCANRSSI = [
        
        ProductType.K4 : -60,
        ProductType.X16 : -60,
        ProductType.Air8 : -50,
        ProductType.NP2Air : -30,
        ProductType.LP2Air : -30,
        ProductType.C4Air : -30,
        ProductType.Power200 : -50,
        ProductType.K2Air : -50,
        ProductType.B80 : -60

    ]
    
    
    static func types(_ id: String) -> ProductType {
        var productType = ProductType.Null
        
        switch id {
        case "01010000","81010000":
            productType = ProductType.K4
            return productType
        case "01020000","81020000":
            productType = ProductType.X16
            return productType
        case "01030000","81030000":
            productType = ProductType.Air8
            return productType
        case "01040000","81040000":
            productType = ProductType.K2Air
            return productType
        case "01050000","81050000":
            productType = ProductType.NP2Air
            return productType
        case "01060000","81060000":
            productType = ProductType.LP2Air
            return productType
        case "01070000","81070000":
            productType = ProductType.C4Air
            return productType
        case "01080000","81080000":
            productType = ProductType.Power200
            return productType
        case "01090000","81090000":
            productType = ProductType.B80
            return productType
        default:
            productType = ProductType.Null
        }
            
        return productType
    }
    
    
}
