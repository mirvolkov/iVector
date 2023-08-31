#if os(macOS)
import AppKit

extension NSImage {
    public convenience init(ciImage: CIImage) {
        let rep = NSCIImageRep(ciImage: ciImage)
        self.init(size: rep.size)
        addRepresentation(rep)
    }
}
#endif
