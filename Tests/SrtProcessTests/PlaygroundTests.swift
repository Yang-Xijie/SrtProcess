import Foundation
@testable import SrtProcess
import XCTest

final class PlaygroundTests: XCTestCase {
    func testDisplayTime() {
        let srt = """
        1
        00:00:00,720 --> 00:00:01,620
        line1 some text

        """
        let nodes = try! srt.srtNodes()
        print(nodes.first!.interval.start.displayString)
    }
}
