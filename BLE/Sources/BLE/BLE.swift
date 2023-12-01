import Combine
import CoreBluetooth
import Foundation
import OSLog

public final class BLE: NSObject, ObservableObject {
    public typealias Callback = (String) -> ()

    internal let logger = OSLog.default
    internal var chips: [String] = []
    internal var bgServices: [CBUUID]? = nil
    internal var queue = DispatchQueue(label: "BLE")

    @Published public var isOnline = false
    @Published public var distance = 0

    internal lazy var manager = CBCentralManager(delegate: self, queue: nil)
    internal var active: CBPeripheral?
    internal var pool: [CBCharacteristic] = []
    internal var callbacks: [CBUUID: Callback] = [:]

    public convenience init(_ chips: [String]) {
        self.init()
        self.chips = chips
    }

    deinit {
        print("BLE deinit")
    }

    public func scan() {
        os_log("manager status %{public}@", log: logger, type: .debug, manager)
    }

    public func disconnect() {
        if let active {
            manager.cancelPeripheralConnection(active)
            self.active = nil
        }
    }
}
