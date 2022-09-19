import Combine
import SwiftUI

protocol CPViewModelConnectable {
    var bag: Set<AnyCancellable> { get }
    var isConnected: Bool { get }
}

