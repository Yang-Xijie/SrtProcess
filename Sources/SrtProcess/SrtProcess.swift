import Foundation

public enum SrtProcess {
    public typealias SrtNodes = [SrtNode]

    public struct SrtNode: Equatable {
        public let index: Int
        public let interval: SrtInterval
        public let text: String
        
        public let originalString: String
    }

    public struct SrtInterval: Equatable {
        public let start: SrtTime
        public let end: SrtTime
    }

    public struct SrtTime: Equatable {
        let hours: Int
        let minutes: Int
        let seconds: Int
        let milliseconds: Int

        enum TimeType: String {
            case hours
            case minutes
            case seconds
            case milliseconds
        }

        init(hours: Int, minutes: Int, seconds: Int, milliseconds: Int) {
            self.hours = hours
            self.minutes = minutes
            self.seconds = seconds
            self.milliseconds = milliseconds
        }

        /// input example: "00:00:01,620"
        init(srtTime: String) {
            let pattern =
                #"(?<hours>\d\d):"# + #"(?<minutes>\d\d):"# + #"(?<seconds>\d\d),"# + #"(?<milliseconds>\d\d\d)"#
            let regex = try! NSRegularExpression(
                pattern: pattern,
                options: []
            )

            let range = NSRange(
                srtTime.startIndex ..< srtTime.endIndex,
                in: srtTime
            )
            let matches = regex.matches(
                in: srtTime,
                options: [],
                range: range
            )
            guard let match = matches.first else {
                fatalError()
            }

            var captures: [TimeType: Int] = [:]
            // For each matched range, extract the named capture group
            for timeType in [TimeType.hours, TimeType.minutes, TimeType.seconds, TimeType.milliseconds] {
                let matchRange = match.range(withName: timeType.rawValue)

                // Extract the substring matching the named capture group
                if let substringRange = Range(matchRange, in: srtTime) {
                    let capture = String(srtTime[substringRange])
                    captures[timeType] = Int(capture)
                }
            }

            self.init(hours: captures[TimeType.hours]!,
                      minutes: captures[TimeType.minutes]!,
                      seconds: captures[TimeType.seconds]!,
                      milliseconds: captures[TimeType.milliseconds]!)
        }
    }

    public enum SrtParser {
        public static func parse(_ string: String) throws -> SrtNodes {
            // Check whether the file is blank or not
            if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return []
            }

            let string = string.trimmingCharacters(in: .newlines)

            // First step, split everything by spaces and newlines
            let originalStrings = string.components(separatedBy: "\n\n")
            var parsedNodes: SrtNodes = []
            for (index, originalString) in originalStrings.enumerated() {
                // Get all rows
                let nodeRows = originalString.components(separatedBy: "\n")

                // And a basic check whether it is fully declared
                guard nodeRows.count >= 3 else {
                    throw SrtParserError.notFullNodeDeclaration(column: 0, row: index)
                }

                guard let nodeIndex = Int(nodeRows[0]) else {
                    throw SrtParserError.badIndexDeclaration(column: 1, row: index)
                }

                let interval = try parseInterval(rawString: nodeRows[1], rowOperatedOn: index + 1)

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

                parsedNodes.append(SrtNode(
                    index: nodeIndex,
                    interval: interval,
                    text: text,
                    originalString: originalString
                ))
            }
            return parsedNodes
        }

        private static func parseInterval(rawString: String, rowOperatedOn row: Int) throws -> SrtInterval {
            let split = rawString.components(separatedBy: " ")

            // Checks that verifies that the structure is alright
            guard split[0].range(of: #"\d\d:\d\d:\d\d,\d\d\d"#, options: .regularExpression) != nil else {
                throw SrtParserError.badTimeIntervalDeclaration(
                    column: 0,
                    row: row
                )
            }

            guard split[1] == "-->" else {
                throw SrtParserError.badTimeIntervalDeclaration(
                    column: split[0].count + 1,
                    row: row
                )
            }

            guard split[2].range(of: #"\d\d:\d\d:\d\d,\d\d\d"#, options: .regularExpression) != nil else {
                throw SrtParserError.badTimeIntervalDeclaration(
                    column: 0,
                    row: row
                )
            }

            return SrtInterval(start: SrtTime(srtTime: split[0]), end: SrtTime(srtTime: split[2]))
        }
    }

    public enum SrtParserError: Error {
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
