//
//  TestButton.swift
//  PureUI
//
//  Created by Wyatt Eberspacher on 6/17/21.
//

import UIKit

public class TestButton: UIButton {
  public init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .lightGray
    layer.cornerRadius = 8
    contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
