//
//  GradientView.swift
//  PureUI
//
//  Created by Wyatt Eberspacher on 6/24/21.
//

import UIKit

/// Offers a method of defining a gradient background for a UIView, before any bounds are known or defined.
public class GradientView: UIView {
  var topColor: UIColor
  var bottomColor: UIColor
  
  public init(topColor: UIColor = UIColor.white,
       bottomColor: UIColor = UIColor.black) {
    self.topColor = topColor
    self.bottomColor = bottomColor
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override class var layerClass: AnyClass {
    return CAGradientLayer.self
  }
  
  public override func layoutSubviews() {
    (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
  }
}
