//
//  UIImageExt.swift
//  SystemExtensions
//
//  Created by Wyatt Eberspacher on 6/24/21.
//

import UIKit

extension UIImage {
  static public func fromUrlString(_ string: String) -> UIImage? {
    guard let imageUrl = URL(string: string),
          let imageData = try? Data(contentsOf: imageUrl)
    else { return nil }
    return UIImage(data: imageData)
  }
}
