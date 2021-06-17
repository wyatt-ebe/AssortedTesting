//
//  ViewController.swift
//  AssortedTesting
//
//  Created by Wyatt Eberspacher on 6/17/21.
//

import UIKit
import PureUI

class ViewController: UIViewController {
  
  lazy var webButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("WebView", for: .normal)
    button.backgroundColor = .lightGray
    button.layer.cornerRadius = 8
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    button.addTarget(self,
                     action: #selector(didTapWebButton),
                     for: .touchUpInside)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .darkGray
    
    view.addSubview(webButton)
    NSLayoutConstraint.activate([
      webButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      webButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    ])
  }

  @objc
  func didTapWebButton() {
    let apple = URL(string: "https://www.apple.com")!
    let webVC = WebViewController(url: apple)
    let navController = UINavigationController(rootViewController: webVC)
    present(navController, animated: true)
  }
}

