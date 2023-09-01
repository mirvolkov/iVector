import BLE
import Combine
import CoreMotion

public protocol Control {
    // gyroscope + compass

    var sonar: PassthroughSubject<PFSonar, Never> { get }
    var battery: PassthroughSubject<Int, Never> { get }

    /// Move
    /// - Parameter distance - distance in mm
    /// - Parameter speed (mm per sec) - default is 1.0 until PWM implemented
    func move(_ distance: Float, speed: Float) async

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

extension PathfinderConnection: Control {
    func listenSensors() {
        ble.listen(for: uuidSonar0) { _ in
        }
    }

    func listenGyro() {
#if os(iOS)
        if motion.isGyroAvailable {
            self.motion.gyroUpdateInterval = 1.0 / 50.0
            self.motion.startGyroUpdates()
            self.timer = Timer(fire: Date(), interval: 1.0 / 50.0,
                               repeats: true, block: { _ in
                                   if let data = self.motion.gyroData {
//                    let x = data.rotationRate.x
//                    let y = data.rotationRate.y
//                    let z = data.rotationRate.z
                                   }
                               })
            RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
        }
#endif
    }

    public func move(_ distance: Float, speed: Float = 1.0) async {}

    public func turn(_ angle: Float, speed: Float = 1.0) async {}

    public func laser(_ isOn: Bool) async {
        let message = isOn ? "1" : "0"
        if let data = message.data(using: .ascii) {
            ble.write(data: data, charID: uuidLaser)
        }
    }

    public func light(_ isOn: Bool) async {
        let message = isOn ? "1" : "0"
        if let data = message.data(using: .ascii) {
            ble.write(data: data, charID: uuidLight)
        }
    }
}
