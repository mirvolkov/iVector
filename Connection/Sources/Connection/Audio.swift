//
//  File.swift
//  
//
//  Created by Miroslav Volkov on 30.08.2022.
//

import Foundation

public struct AudioFrame {
    
}

protocol Audio {
    /// Request Vector's mic feed
    /// - Returns AsyncStream type with frame
    /// - Throws error if request failed
    func requestCameraFeed() throws -> AsyncStream<AudioFrame>
}
