// swiftlint:disable:next file_header
import BLE
import Combine
import CoreMotion

public protocol PathfinderControl {
    var sonar: PassthroughSubject<PFSonar, Never> { get }
    var battery: PassthroughSubject<UInt, Never> { get }
    var headAngle: PassthroughSubject<Float, Never> { get }

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

    /// Set head angle
    /// - Parameter angle 22..45 range
    /// - Throws set angle error failed
    func setHeadAngle(_ angle: Float) async
}

extension PathfinderConnection: PathfinderControl {
    internal func listenSensors() {
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

        ble.listen(for: uuidHeadAngle) { [self] message in
            if let value = Float(message) {
                headAngle.send(value)
            }
        }
    }

    public func move(_ distance: Float, speed: Float = 1.0, direction: Bool = true) async {
        await write(direction ? 255 : 0, uuid: uuidEngineLF)
        await write(direction ? 255 : 0, uuid: uuidEngineRF)
        await write(direction ? 0 : 255, uuid: uuidEngineLB)
        await write(direction ? 0 : 255, uuid: uuidEngineRB)
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * abs(distance) / 100.0))
        await write(0, uuid: uuidEngineLF)
        await write(0, uuid: uuidEngineRF)
        await write(0, uuid: uuidEngineLB)
        await write(0, uuid: uuidEngineRB)
    }

    public func turn(_ angle: Float, speed: Float = 1.0) async {
        let direction = angle > 0
        await write(direction ? 255 : 0, uuid: uuidEngineLF)
        await write(direction ? 255 : 0, uuid: uuidEngineRB)
        await write(direction ? 0 : 255, uuid: uuidEngineLB)
        await write(direction ? 0 : 255, uuid: uuidEngineRF)
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * abs(angle * 180 / Float.pi) / 100.0))
        await write(0, uuid: uuidEngineLF)
        await write(0, uuid: uuidEngineRF)
        await write(0, uuid: uuidEngineLB)
        await write(0, uuid: uuidEngineRB)
    }

    public func laser(_ isOn: Bool) async {
        await write(isOn ? 1 : 0, uuid: uuidLaser)
    }

    public func light(_ isOn: Bool) async {
        await write(isOn ? 1 : 0, uuid: uuidLight)
    }

    public func setHeadAngle(_ angle: Float) async {
        await write(angle, uuid: uuidHeadAngle)
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

    private func write<T: CustomStringConvertible>(_ value: T, uuid: String) async {
        if let data = value.description.data(using: .ascii) {
            ble.write(data: data, charID: uuid)
        }
    }
}
