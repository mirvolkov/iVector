import CoreBluetooth
import OSLog

extension BLE: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        os_log("didDiscoverServices %{public}@", log: logger, type: .debug, peripheral.description)
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        os_log("didDiscoverCharacteristicsFor %{public}@", log: logger, type: .debug, service.description)
        pool.append(contentsOf: service.characteristics?.compactMap { $0 } ?? [])
        isOnline = true
        // if there is a callback waiting for characteristic to listen -> add listener
        for (charID, _) in callbacks {
            if let active, let ch = pool.first(where: { $0.uuid == charID }) {
                active.setNotifyValue(true, for: ch)
            }
        }
    }

    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let value = characteristic.value,
           let message = String(data: value, encoding: .utf8),
           let callback = callbacks.first(where:  { $0.key == characteristic.uuid} ){
            callback.value(message.replacingOccurrences(of: "\n", with: ""))
        }
    }
}
