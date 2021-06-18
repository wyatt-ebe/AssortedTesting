//
//  BluetoothManagerTestViewController.swift
//  AssortedTesting
//
//  Created by Wyatt Eberspacher on 6/17/21.
//

import Foundation
import SystemTools
import PureUI
import UIKit


// Not really used, but if had protocols for plist could use to find specific protocol-compliant non-BLE devices
import ExternalAccessory

// Learnings: Bluetooth Low Energy devices preferable (required for CoreBluetooth).
// With BLE, a "connection" is not guaranteed, aka the "connected" text in the device settings does not translate to CBCentralManager connection.
// If we know what CBUUID(s) our bluetooth device is using, we can scan/search existing connections directly.
// CBUUIDs can be guessed from the published list, or provided from device specifications.
// There is some other way to do this for audio devices, though many new audio devices appeared as BLE.

class BluetoothManagerTestViewController: UIViewController {
  let bluetoothManager = BluetoothManager()
  
  lazy var accesoriesButton: UIButton = {
    let button = TestButton()
    button.setTitle("List Accessories (EA)", for: .normal)
    button.addTarget(self,
                     action: #selector(didTapAccessoriesButton),
                     for: .touchUpInside)
    return button
  }()
  
  lazy var listConnectionsButton: UIButton = {
    let button = TestButton()
    button.setTitle("List Connections (BLE)", for: .normal)
    button.addTarget(self,
                     action: #selector(didTapConnectionsButton),
                     for: .touchUpInside)
    return button
  }()
  
  // Will actually currently scan and connect as part of the manager connecting to every scaned device to list out services
  lazy var scanButton: UIButton = {
    let button = TestButton()
    button.setTitle("Begin Scan (BLE)", for: .normal)
    button.addTarget(self,
                     action: #selector(didTapScanButton),
                     for: .touchUpInside)
    return button
  }()
  
  lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.clipsToBounds = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()
  
  lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = 8
    return stackView
  }()
  
  override func viewDidLoad() {
    // Set up navigation bar
    navigationController?.navigationBar.backgroundColor = .systemGray
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                       target: self,
                                                       action: #selector(closeView))
    view.backgroundColor = .darkGray
    
    bluetoothManager.delegate = self
    
    view.addSubview(accesoriesButton)
    NSLayoutConstraint.activate([
      accesoriesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      accesoriesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    ])
    
    view.addSubview(listConnectionsButton)
    NSLayoutConstraint.activate([
      listConnectionsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      listConnectionsButton.topAnchor.constraint(equalTo: accesoriesButton.bottomAnchor, constant: 16),
    ])
    
    view.addSubview(scanButton)
    NSLayoutConstraint.activate([
      scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      scanButton.topAnchor.constraint(equalTo: listConnectionsButton.bottomAnchor, constant: 16),
    ])
    
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 24),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    scrollView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
    ])
  }
  
  @objc
  private func closeView() {
    presentingViewController?.dismiss(animated: true)
  }
  
  @objc
  func didTapAccessoriesButton() {
    // EAAcessory would require plist update with specific device protocols -> would need to have already included by manufacturer.
    let accessories = EAAccessoryManager.shared().connectedAccessories
    let accessoryNames = accessories.map{ $0.name }
    print(accessoryNames)
  }
  
  @objc
  func didTapConnectionsButton() {
    bluetoothManager.listConnected()
  }
  
  @objc
  func didTapScanButton() {
    for view in stackView.arrangedSubviews {
      view.removeFromSuperview()
    }
    bluetoothManager.performScan()
  }
}

extension BluetoothManagerTestViewController: BluetoothManagerDelegate {
  func didDiscoverDevice(name peripheralName: String?) {
    guard let peripheralName = peripheralName else { return }
    let label = UILabel()
    label.text = peripheralName
    label.backgroundColor = .lightGray.withAlphaComponent(0.6)
    label.layer.cornerRadius = 12
    stackView.addArrangedSubview(label)
  }
}
