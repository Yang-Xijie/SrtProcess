import Foundation

public enum SrtProcess {
    public typealias SubRipNodes = [SubRipNode]

    public struct SubRipNode {
        public let index: Int
        public let interval: SrtInterval
        public let text: String
    }

    public struct SrtInterval {
        public let start: SrtTime
        public let end: SrtTime
    }

    public struct SrtTime {
        let hours: Int
        let minutes: Int
        let seconds: Int
        let milliseconds: Int
        
        init(hours: Int, minutes: Int, seconds: Int, milliseconds: Int) {
            self.hours = hours
            self.minutes = minutes
            self.seconds = seconds
            self.milliseconds = milliseconds
        }
        
        init(srtTime: String) {
            self.init(hours: 0, minutes: 0, seconds: 0, milliseconds: 0)
        }
    }

    public struct SubRipParser {
        public typealias Input = String
        public typealias Output = SubRipNodes

        public var fileContent: Input

        public init(content: Input) {
            self.fileContent = content
        }

        public func parse() throws -> Output {
            // Check whether the file is blank or not
            if fileContent.isBlank {
                return []
            }
            // First step, split everything by spaces and newlines
            let nodes = fileContent.components(separatedBy: "\n\n")
            var parsedNodes: Output = []
            for (index, node) in nodes.enumerated() {
                // Get all rows
                let nodeRows = node.components(separatedBy: "\n")

                // And a basic check whether it is fully declared
                guard nodeRows.count >= 3 else {
                    throw SubRipParserError.notFullNodeDeclaration(column: 0, row: index)
                }

                guard let nodeIndex = Int(nodeRows[0]) else {
                    throw SubRipParserError.badIndexDeclaration(column: 1, row: index)
                }

                let timeInterval = try parseTimeInterval(rawString: nodeRows[1], rowOperatedOn: index + 1)

                var textRows = nodeRows
                textRows.remove(at: 0)
                textRows.remove(at: 0)

                var text = ""
                for (index, row) in textRows.enumerated() {
                    text.append(row)
                    if index < textRows.count - 1 {
                        text.append("\n")
                    }
                }

                parsedNodes.append(SubRipNode(
                    index: nodeIndex,
                    interval: timeInterval,
                    text: text
                ))
            }
            return parsedNodes
        }

        private func parseTimeInterval(rawString: String, rowOperatedOn row: Int) throws -> SrtInterval {
            let split = rawString.components(separatedBy: " ")

            // Checks that verifies that the structure is alright
            guard split[0].range(of: #"\d\d:\d\d:\d\d,\d\d\d"#, options: .regularExpression) != nil else {
                throw SubRipParserError.badTimeIntervalDeclaration(
                    column: 0,
                    row: row
                )
            }

            guard split[1] == "-->" else {
                throw SubRipParserError.badTimeIntervalDeclaration(
                    column: split[0].count + 1,
                    row: row
                )
            }

            guard split[2].range(of: #"\d\d:\d\d:\d\d,\d\d\d"#, options: .regularExpression) != nil else {
                throw SubRipParserError.badTimeIntervalDeclaration(
                    column: 0,
                    row: row
                )
            }

            return SrtInterval(start: SrtTime(srtTime: split[0]), end: SrtTime(srtTime: split[2]))
        }
    }

    public enum SubRipParserError: Error {
        case badIndexDeclaration(column: Int, row: Int)
        case badTimeIntervalDeclaration(column: Int, row: Int)
        case notFullNodeDeclaration(column: Int, row: Int)

        var message: String {
            switch self {
            case .badIndexDeclaration:
                return "Bad subtitle node declaration"
            case .badTimeIntervalDeclaration:
                return "Bad time interval declaration. Expected format: 'hours:minutes:seconds,milliseconds (00:00:00,000)'"
            case .notFullNodeDeclaration:
                return "A node is not fully declared"
            }
        }
    }
}
