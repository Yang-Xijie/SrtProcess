import Foundation
@testable import SrtProcess
import XCTest

final class SrtProcessTests: XCTestCase {
    func testSingle() throws {
//        XCTAssertEqual(SrtProcess().text, "Hello, World!")
        let srt = """
        1
        00:00:00,720 --> 00:00:01,620
        some text
        
        """
        let nodes = try! srt.srtNodes()
        XCTAssertEqual(nodes.first!.index, 1)
        XCTAssertEqual(nodes.first!.text, "some text\n")
        XCTAssertEqual(nodes.first!.interval.start.seconds, 0)
        XCTAssertEqual(nodes.first!.interval.start.milliseconds, 720)
        XCTAssertEqual(nodes.first!.interval.end.seconds, 1)
        XCTAssertEqual(nodes.first!.interval.end.milliseconds, 620)
    }
}
