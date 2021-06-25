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
    let button = TestButton()
    button.setTitle("WebView", for: .normal)
    button.addTarget(self,
                     action: #selector(didTapWebButton),
                     for: .touchUpInside)
    return button
  }()
  
  lazy var volumeListenerButton: UIButton = {
    let button = TestButton()
    button.setTitle("VolumeListener", for: .normal)
    button.addTarget(self,
                     action: #selector(didTapVolumeListenerButton),
                     for: .touchUpInside)
    return button
  }()
  
  lazy var bluetoothManagerButton: UIButton = {
    let button = TestButton()
    button.setTitle("BluetoothManager", for: .normal)
    button.addTarget(self,
                     action: #selector(didTapBluetoothManagerButton),
                     for: .touchUpInside)
    return button
  }()
  
  lazy var cardCollectionButton: UIButton = {
    let button = TestButton()
    button.setTitle("CardCollection", for: .normal)
    button.addTarget(self,
                     action: #selector(didTapCardCollectionButton),
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
    
    view.addSubview(volumeListenerButton)
    NSLayoutConstraint.activate([
      volumeListenerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      volumeListenerButton.topAnchor.constraint(equalTo: webButton.bottomAnchor, constant: 16),
    ])
    
    view.addSubview(bluetoothManagerButton)
    NSLayoutConstraint.activate([
      bluetoothManagerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bluetoothManagerButton.topAnchor.constraint(equalTo: volumeListenerButton.bottomAnchor, constant: 16),
    ])
    
    view.addSubview(cardCollectionButton)
    NSLayoutConstraint.activate([
      cardCollectionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      cardCollectionButton.topAnchor.constraint(equalTo: bluetoothManagerButton.bottomAnchor, constant: 16),
    ])
    
    // Preload stuff
    CardMedia.preloadImages()
  }

  @objc
  func didTapWebButton() {
    let apple = URL(string: "https://www.apple.com")!
    let webVC = WebViewController(url: apple)
    let navController = UINavigationController(rootViewController: webVC)
    present(navController, animated: true)
  }
  
  @objc
  func didTapVolumeListenerButton() {
    let listenerVC = VolumeListenerTestViewController()
    let navController = UINavigationController(rootViewController: listenerVC)
    present(navController, animated: true)
  }
  
  @objc
  func didTapBluetoothManagerButton() {
    let bluetoothVC = BluetoothManagerTestViewController()
    let navController = UINavigationController(rootViewController: bluetoothVC)
    present(navController, animated: true)
  }
  
  @objc
  func didTapCardCollectionButton() {
    let cardVC = CardCollectionTestViewController()
    let navController = UINavigationController(rootViewController: cardVC)
    present(navController, animated: true)
  }
}

