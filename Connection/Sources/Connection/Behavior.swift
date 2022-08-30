//
//  File.swift
//  
//
//  Created by Miroslav Volkov on 30.08.2022.
//

import Foundation

public protocol Behavior {
    /// Request vector say some text
    /// - Throws error if request failed
    func say(text: String) throws
    
    
    /// Sets eye color
    /// - Parameter hue value 0..1
    /// - Throws error set eye color failed
    func setEyeColor(_ hue: Float, _ sat: Float) async throws 


    /// Set head angle
    /// - Parameter angle 22.000000..45.000000 range
    /// - Throws set angle error failed
    func setHeadAngle(_ angle: Float) async throws
}
