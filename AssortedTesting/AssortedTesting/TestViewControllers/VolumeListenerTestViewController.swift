//
//  VolumeListenerTestViewController.swift
//  AssortedTesting
//
//  Created by Wyatt Eberspacher on 6/17/21.
//

import Foundation
import SystemTools
import SystemExtensions
import UIKit

class VolumeListenerTestViewController: UIViewController {
  let volumeListener = VolumeListener()
  
  let circleDiameter: CGFloat = 40
  let ringBorderWidth: CGFloat = 4
  let ringOffset: CGFloat = 1
  
  var ringDiameter: CGFloat {
    return circleDiameter + 2 * (ringBorderWidth + ringOffset)
  }
  
  lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    let text = "Trigger a volume change event to change the button transparency below."
    label.attributedText = NSAttributedString(string: text,
                                              font: label.font,
                                              color: label.textColor,
                                              lineSpacing: 6,
                                              alignment: .center)
    return label
  }()
  
  lazy var whiteRing: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = ringDiameter/2
    view.layer.borderWidth = ringBorderWidth
    view.layer.borderColor = UIColor.white.cgColor
    return view
  }()
  
  lazy var redCircle: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = circleDiameter/2
    view.backgroundColor = UIColor.red
    return view
  }()
  
  // Great to confirm no memory leaks
  deinit {
    print("deinit \(type(of: self))")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set up navigation bar
    navigationController?.navigationBar.backgroundColor = .systemGray
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                       target: self,
                                                       action: #selector(closeView))
    view.backgroundColor = .darkGray
    
    view.addSubview(whiteRing)
    view.addSubview(redCircle)
    view.addSubview(descriptionLabel)
    NSLayoutConstraint.activate([
      whiteRing.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      whiteRing.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      whiteRing.widthAnchor.constraint(equalToConstant: ringDiameter),
      whiteRing.heightAnchor.constraint(equalToConstant: ringDiameter),
      
      redCircle.centerXAnchor.constraint(equalTo: whiteRing.centerXAnchor),
      redCircle.centerYAnchor.constraint(equalTo: whiteRing.centerYAnchor),
      redCircle.widthAnchor.constraint(equalToConstant: circleDiameter),
      redCircle.heightAnchor.constraint(equalToConstant: circleDiameter),
      
      descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
      descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
      descriptionLabel.bottomAnchor.constraint(equalTo: whiteRing.topAnchor, constant: -16),
    ])
    
    volumeListener.delegate = self
    view.addSubview(volumeListener.volumeView)
  }
  
  @objc
  private func closeView() {
    presentingViewController?.dismiss(animated: true)
  }
}

extension VolumeListenerTestViewController: VolumeListenerDelegate {
  func volumeChanged() {
    if redCircle.alpha == 1 {
      redCircle.alpha = 0.2
    } else {
      redCircle.alpha = 1
    }
  }
}
