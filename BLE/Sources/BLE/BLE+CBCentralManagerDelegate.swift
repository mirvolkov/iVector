import CoreBluetooth
import OSLog

extension BLE: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOff:
                os_log("Is Powered Off.", log: logger, type: .debug)
            case .poweredOn:
                os_log("Is Powered On.", log: logger, type: .debug)
                central.scanForPeripherals(withServices: [], options: nil)
            case .unsupported:
                os_log("Is Powered Off.", log: logger, type: .debug)
            case .unauthorized:
                os_log("Is Unauthorized.", log: logger, type: .debug)
            case .resetting:
                os_log("Resetting", log: logger, type: .debug)
            case .unknown:
                os_log("Unknown error", log: logger, type: .error)
            @unknown default:
                os_log("Unknown case", log: logger, type: .debug)
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, chips.contains(name) {
            active = peripheral
            active?.delegate = self
            manager.connect(peripheral, options: nil)
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("didConnectPeripheral %{public}@", log: logger, type: .debug, peripheral.description)
        active?.discoverServices(nil)
        active?.readRSSI()
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("didDisconnectPeripheral %{public}@", log: logger, type: .debug, peripheral.description)
        active = nil
        isOnline = false
        pool.removeAll()
        manager.scanForPeripherals(withServices: nil, options: [CBConnectPeripheralOptionNotifyOnConnectionKey: true])
    }

    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        distance = RSSI.intValue
        peripheral.readRSSI()
    }
}

