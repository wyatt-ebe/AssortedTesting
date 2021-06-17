//
//  NSAttributedStringExt.swift
//  SystemExtensions
//
//  Created by Wyatt Eberspacher on 6/17/21.
//

import UIKit

public extension NSAttributedString {
  // Returns an attributed string with the given text, font, color, and line spacing.
  convenience init(string: String,
                   font: UIFont,
                   color: UIColor,
                   lineSpacing: CGFloat? = nil,
                   kern: CGFloat? = nil,
                   alignment: NSTextAlignment? = nil) {
    
    let paragraphStyle = NSMutableParagraphStyle()
    if let lineSpacing = lineSpacing {
      paragraphStyle.lineSpacing = lineSpacing
    }

    if let alignment = alignment {
      paragraphStyle.alignment = alignment
    }

    var attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraphStyle,
      ]

    if let kern = kern {
      attributes[.kern] = kern
    }

    self.init(string: string,
              attributes: attributes)
  }
}
