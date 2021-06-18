//
//  BluetoothManager.swift
//  SystemTools
//
//  Created by Wyatt Eberspacher on 6/17/21.
//

import Foundation
import CoreBluetooth

public protocol BluetoothManagerDelegate: AnyObject {
  func didDiscoverDevice(name peripheralName: String?)
}

// Learnings: Bluetooth Low Energy devices preferable (required for CoreBluetooth).
// With BLE, a "connection" is not guaranteed, aka the "connected" text in the device settings does not translate to CBCentralManager connection.
// If we know what CBUUID(s) our bluetooth device is using, we can scan/search existing connections directly.
// CBUUIDs can be guessed from the published list, or provided from device specifications.
// There is some other way to do this for audio devices, though many new audio devices appeared as BLE.

public class BluetoothManager: NSObject {
  var centralManager: CBCentralManager?
  public weak var delegate: BluetoothManagerDelegate?
  
  var discoveredUUIDs = Set<UUID>()
  var discoveredPeripherals = Set<CBPeripheral>()
  
  override public init() {
    super.init()
    centralManager = CBCentralManager(delegate: self,
                                      queue: .main)
  }
  
  // Great to confirm no memory leaks
  deinit {
    print("deinit \(type(of: self))")
  }
  
  public func performScan() {
    discoveredUUIDs = Set<UUID>()
    discoveredPeripherals = Set<CBPeripheral>()
    let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)]
    centralManager?.scanForPeripherals(withServices: nil, options: options)
  }
  
  public func listConnected() {
    let volumeControlCBUUID = CBUUID(string: "1844")
    let bootKeyboardInputCBUUID = CBUUID(string: "2A22")
    let deviceInformationCBUUID = CBUUID(string: "180A")
    let connects = centralManager?.retrieveConnectedPeripherals(withServices: [volumeControlCBUUID,
                                                                               bootKeyboardInputCBUUID,
                                                                               deviceInformationCBUUID])
    print(connects ?? [])
  }
}

extension BluetoothManager: CBCentralManagerDelegate {
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("centralManager state changed: \(central.state.rawValue)")
  }
  
  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    // Would otherwise repeatedly discover certain BLE devices
    guard !discoveredUUIDs.contains(peripheral.identifier) else { return }
    
    // Only required to print out all the services for connectible peripherals, would nominally not be needed if we had searched by known CBUUID.
    discoveredUUIDs.insert(peripheral.identifier)
    discoveredPeripherals.insert(peripheral)
    central.connect(peripheral)

    delegate?.didDiscoverDevice(name: peripheral.name)
  }
  
  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("Connected to \(peripheral.name ?? "nil name")")
    peripheral.delegate = self
    peripheral.discoverServices(nil)
  }
  
  public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print("Failed to connect to \(peripheral.name ?? "nil name")")
  }
}

// Only occurs if device has services.
extension BluetoothManager: CBPeripheralDelegate {
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print("didDiscoverServices,\n id: \(peripheral.identifier),\n name: \(peripheral.name ?? "nil name"),\n services: \(peripheral.services ?? [])")
  }
}
