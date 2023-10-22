// swiftlint:disable:next file_header
import BLE
import Combine
import CoreMotion

public protocol PathfinderControl {
    var sonar: PassthroughSubject<PFSonar, Never> { get }
    var battery: PassthroughSubject<UInt, Never> { get }

    /// Move
    /// - Parameter distance - distance in mm
    /// - Parameter speed (mm per sec) - default is 1.0 until PWM implemented
    /// - Parameter direction(bool) 1 - forward, 0 - backward
    func move(_ distance: Float, speed: Float, direction: Bool) async

    /// Turn in place
    /// - Parameter angle (rad)
    /// - Parameter speed (mm per sec) - default is 1.0 until PWM implemented
    func turn(_ angle: Float, speed: Float) async

    /// Turn on/off the light
    /// - Parameter isOn (boolean)
    func light(_ isOn: Bool) async

    /// Turn on/off the laser
    /// - Parameter isOn (boolean)
    func laser(_ isOn: Bool) async
}

extension PathfinderConnection: PathfinderControl {
    // swiftlint:disable:next force_unwrapping
    private static let zero: Data = "0".data(using: .ascii)!
    // swiftlint:disable:next force_unwrapping
    private static let one: Data = "1".data(using: .ascii)!

    private func listenSonar(uuid: String) -> PassthroughSubject<UInt, Never> {
        let listener = PassthroughSubject<UInt, Never>()
        ble.listen(for: uuidSonar0) { message in
            if let value = UInt(message) {
                listener.send(value)
            }
        }
        return listener
    }

    private func listenSensors() {
        listenSonar(uuid: uuidSonar0)
            .zip(listenSonar(uuid: uuidSonar1), listenSonar(uuid: uuidSonar2), listenSonar(uuid: uuidSonar3))
            .map { PFSonar($0) }
            .sink(receiveValue: { self.sonar.send($0) })
            .store(in: &bag)

        ble.listen(for: uuidBattery) { [self] message in
            if let value = UInt(message) {
                battery.send(value)
            }
        }
    }

    public func move(_ distance: Float, speed: Float = 1.0, direction: Bool = true) async {
        ble.write(data: direction ? Self.one : Self.zero, charID: uuidEngineLF)
        ble.write(data: direction ? Self.one : Self.zero, charID: uuidEngineRF)
        ble.write(data: direction ? Self.zero : Self.one, charID: uuidEngineLB)
        ble.write(data: direction ? Self.zero : Self.one, charID: uuidEngineRB)
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * abs(distance) / 100.0))
        ble.write(data: Self.zero, charID: uuidEngineLF)
        ble.write(data: Self.zero, charID: uuidEngineRF)
        ble.write(data: Self.zero, charID: uuidEngineLB)
        ble.write(data: Self.zero, charID: uuidEngineRB)
    }

    public func turn(_ angle: Float, speed: Float = 1.0) async {
        let direction = angle > 0
        ble.write(data: direction ? Self.one : Self.zero, charID: uuidEngineLF)
        ble.write(data: direction ? Self.one : Self.zero, charID: uuidEngineRB)
        ble.write(data: direction ? Self.zero : Self.one, charID: uuidEngineLB)
        ble.write(data: direction ? Self.zero : Self.one, charID: uuidEngineRF)
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * abs(angle * 180 / Float.pi) / 100.0))
        ble.write(data: Self.zero, charID: uuidEngineLF)
        ble.write(data: Self.zero, charID: uuidEngineRF)
        ble.write(data: Self.zero, charID: uuidEngineLB)
        ble.write(data: Self.zero, charID: uuidEngineRB)
    }

    public func laser(_ isOn: Bool) async {
        ble.write(data: isOn ? Self.one : Self.zero, charID: uuidLaser)
    }

    public func light(_ isOn: Bool) async {
        ble.write(data: isOn ? Self.one : Self.zero, charID: uuidLight)
    }
}
