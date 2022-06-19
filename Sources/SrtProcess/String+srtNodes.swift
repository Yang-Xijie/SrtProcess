import Foundation

extension String {
    func srtNodes() throws -> SrtProcess.SrtNodes {
        return try SrtProcess.SrtParser.parse(self)
    }
}
