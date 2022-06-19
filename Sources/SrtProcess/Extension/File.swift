// File.swift

import Foundation


extension String {
    func parseSrt() throws -> SrtProcess.SubRipNodes {
        let parser = SrtProcess.SubRipParser(content: self)
        return try parser.parse()
    }
}
