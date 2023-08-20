import CoreBluetooth

public protocol BLEIO {
    func write(data: Data, charID: String)
    func listen(for charID: String, callback: @escaping BLE.Callback)
}

extension BLE: BLEIO {
    public func write(data: Data, charID: String) {
        if let active, let ch = pool.first(where: { $0.uuid == CBUUID(string: charID) }) {
            queue.async {
                active.writeValue(data, for: ch, type: .withResponse)
                active.setNotifyValue(true, for: ch)
            }
        }
    }

    public func listen(for charID: String, callback: @escaping Callback) {
        callbacks[CBUUID(string: charID)] = callback
    }
}
