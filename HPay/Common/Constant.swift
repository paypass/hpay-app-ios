//
//  File.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import Foundation
import UIKit

let baseUrl = ""

public func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
public func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 1.0)
}

enum Storyboard: String {
    case main = "Main"
}

let objColors = [RGB(73, 53, 216), RGB(237, 121, 117), RGB(85, 169, 141), RGB(177, 122, 215), RGB(229, 65, 97), RGB(238, 129, 49), RGB(141, 235, 210), RGB(126, 193, 235), RGB(53, 121, 247)]
