// swiftlint:disable:next file_header
import BLE
import Combine
import CoreMotion

public protocol PathfinderControl {
    var sonar: PassthroughSubject<PFSonar, Never> { get }
    var battery: PassthroughSubject<UInt, Never> { get }
    var headAngle: PassthroughSubject<Float, Never> { get }
    var power: PassthroughSubject<Bool, Never> { get }
    var proximity: PassthroughSubject<UInt, Never> { get }

    /// Move
    /// - Parameter distance - distance in mm
    /// - Parameter speed (0...255)
    /// - Parameter direction(bool) 1 - forward, 0 - backward
    func move(_ distance: Float, speed: UInt8, direction: Bool) async throws

    /// Turn in place
    /// - Parameter angle (rad)
    /// - Parameter speed (0...255)
    func turn(_ angle: Float, speed: UInt8) async throws

    /// Turn on/off the light
    /// - Parameter isOn (boolean)
    func light(_ isOn: Bool) async

    /// Turn on/off the laser
    /// - Parameter isOn (boolean)
    func laser(_ isOn: Bool) async

    /// Set head angle
    /// - Parameter angle 22..45 range
    /// - Throws set angle error failed
    func setHeadAngle(_ angle: Float) async
}

extension PathfinderConnection: PathfinderControl {
    internal func listenSensors() {
        listenSonar(uuid: Const.uuidSonar0)
            .zip(
                listenSonar(uuid: Const.uuidSonar1),
                listenSonar(uuid: Const.uuidSonar2),
                listenSonar(uuid: Const.uuidSonar3)
            )
            .map { PFSonar($0) }
            .sink(receiveValue: { self.sonar.send($0) })
            .store(in: &bag)

        ble.listen(for: Const.uuidBattery) { [self] message in
            if let value = UInt(message) {
                battery.send(value)
            }
        }

        ble.listen(for: Const.uuidHeadAngle) { [self] message in
            if let value = Float(message) {
                headAngle.send(value)
            }
        }

        ble.listen(for: Const.uuidPower) { [self] message in
            if let value = UInt(message) {
                power.send(value > 0)
            }
        }

        ble.listen(for: Const.uuidProximity) { [self] message in
            if let value = UInt(message) {
                proximity.send(value)
            }
        }
    }

    public func move(_ distance: Float, speed: UInt8 = 255, direction: Bool = true) async throws {
        write(direction ? speed : 0, uuid: Const.uuidEngineLF)
        write(direction ? speed : 0, uuid: Const.uuidEngineRF)
        write(direction ? 0 : speed, uuid: Const.uuidEngineLB)
        write(direction ? 0 : speed, uuid: Const.uuidEngineRB)
        write(1, uuid: Const.uuidPower)
        try await Task.sleep(for: .microseconds(UInt64(1_000_000 * abs(distance) / 100.0)))
        write(0, uuid: Const.uuidPower)
        write(0, uuid: Const.uuidEngineLF)
        write(0, uuid: Const.uuidEngineRF)
        write(0, uuid: Const.uuidEngineLB)
        write(0, uuid: Const.uuidEngineRB)
        try await Task.sleep(for: .milliseconds(10))
    }

    public func turn(_ angle: Float, speed: UInt8 = 255) async throws {
        let direction = angle > 0
        write(direction ? speed : 0, uuid: Const.uuidEngineLF)
        write(direction ? speed : 0, uuid: Const.uuidEngineRB)
        write(direction ? 0 : speed, uuid: Const.uuidEngineLB)
        write(direction ? 0 : speed, uuid: Const.uuidEngineRF)
        write(1, uuid: Const.uuidPower)
        try await Task.sleep(for: .milliseconds(UInt64(1_000 * abs(angle) / 100.0)))
        write(0, uuid: Const.uuidPower)
        write(0, uuid: Const.uuidEngineLF)
        write(0, uuid: Const.uuidEngineRF)
        write(0, uuid: Const.uuidEngineLB)
        write(0, uuid: Const.uuidEngineRB)
        try await Task.sleep(for: .milliseconds(10))
    }

    public func laser(_ isOn: Bool) async {
        write(isOn ? 1 : 0, uuid: Const.uuidLaser)
    }

    public func light(_ isOn: Bool) async {
        write(isOn ? 1 : 0, uuid: Const.uuidLight)
    }

    public func setHeadAngle(_ angle: Float) async {
        write(angle, uuid: Const.uuidHeadAngle)
        try? await Task.sleep(for: .milliseconds(300))
    }

    private func listenSonar(uuid: String) -> PassthroughSubject<UInt, Never> {
        let listener = PassthroughSubject<UInt, Never>()
        ble.listen(for: uuid) { message in
            if let value = UInt(message) {
                listener.send(value)
            }
        }
        return listener
    }

    private func write<T: CustomStringConvertible>(_ value: T, uuid: String) {
        if let data = value.description.data(using: .ascii) {
            ble.write(data: data, charID: uuid)
        }
    }
}
