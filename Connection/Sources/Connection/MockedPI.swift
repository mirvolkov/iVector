// swiftlint:disable:next file_header

/**
 This is pseudo-random generator based on PI number sequence.
 The goal of using it is to get some sort of random but still chunk-recognized output
 It supposed to be processed and recognized by AI in future trainings
 */

// swiftlint:disable line_length
// swiftlint:disable identifier_name
private let pi = "3141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273724587006606315588174881520920962829254091715364367892590360011330530548820466521384146951941511609433057270365759591953092186117"

public final class MockedPI: IteratorProtocol {
    public typealias Voxel = [UInt]

    private var length: Int { pi.count }
    private var index: Int { Int.random(in: 0 ..< pi.count - size) }
    private let size: Int

    init(size: Int = 4) {
        self.size = size
    }

    public func next() -> Voxel? {
        let pointer = index
        let start = pi.index(pi.startIndex, offsetBy: pointer)
        let end = pi.index(pi.startIndex, offsetBy: pointer + size)
        let chunk = pi[start ..< end]
        return chunk.map { UInt(String($0)) }.compactMap { $0 }
    }
}

// swiftlint:enable line_length
// swiftlint:enable identifier_name
