//
//  UIFontExt.swift
//  SystemExtensions
//
//  Created by Wyatt Eberspacher on 6/24/21.
//

import UIKit

extension UIFont {
  static public let larsseitSmall = getSizedFont(font: .larsseit, size: .small)
  static public let larsseitMedium = getSizedFont(font: .larsseit, size: .medium)
  static public let larsseitLarge = getSizedFont(font: .larsseit, size: .large)
}

fileprivate enum CustomFont: String {
  case larsseit = "Larsseit"
}

fileprivate enum CustomFontSize: CGFloat {
  case small = 14
  case medium = 18
  case large = 28
}

fileprivate func getSizedFont(font: CustomFont, size: CustomFontSize) -> UIFont {
  guard let sizedFont = UIFont(name: font.rawValue, size: size.rawValue) else {
    print("Error: Custom Font \(font.rawValue) not found")
    return UIFont.systemFont(ofSize: size.rawValue)
  }
  return sizedFont
}
