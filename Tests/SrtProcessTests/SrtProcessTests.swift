import Foundation
@testable import SrtProcess
import XCTest

final class SrtProcessTests: XCTestCase {
    
    func testSingle() {
        let srt = """
        1
        00:00:00,720 --> 00:00:01,620
        line1 some text

        """
        let nodes = try! srt.srtNodes()
        XCTAssertEqual(nodes[0],
                       SrtProcess.SrtNode(index: 1,
                                          interval: SrtProcess.SrtInterval(start: SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 0, milliseconds: 720),
                                                                           end: SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 1, milliseconds: 620)),
                                          text: "line1 some text"))
    }

    func testMultiple() {
        let srt = """
        1
        00:00:00,720 --> 00:00:01,620
        line1 some text

        2
        00:00:01,620 --> 00:00:05,910
        line2 some text
        """
        let nodes = try! srt.srtNodes()
        XCTAssertEqual(nodes[0],
                       SrtProcess.SrtNode(index: 1,
                                          interval: SrtProcess.SrtInterval(start: SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 0, milliseconds: 720),
                                                                           end: SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 1, milliseconds: 620)),
                                          text: "line1 some text"))
        XCTAssertEqual(nodes[1],
                       SrtProcess.SrtNode(index: 2,
                                          interval: SrtProcess.SrtInterval(start: SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 1, milliseconds: 620),
                                                                           end: SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 5, milliseconds: 910)),
                                          text: "line2 some text"))
    }

    func testSingleMultipleLines() {
        let srt = """
        1
        00:00:00,720 --> 00:00:01,620
        line1 some text
        line2 some text

        """
        let nodes = try! srt.srtNodes()
        XCTAssertEqual(nodes[0],
                       SrtProcess.SrtNode(index: 1,
                                          interval: SrtProcess.SrtInterval(start: SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 0, milliseconds: 720),
                                                                           end: SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 1, milliseconds: 620)),
                                          text: "line1 some text\nline2 some text"))
    }

    func testOrigin() {
        let srt = """
        1
        00:00:00,720 --> 00:00:01,620
        line1 some text

        """
        let nodes = try! srt.srtNodes()
        XCTAssertEqual(nodes[0].origin, """
        1
        00:00:00,720 --> 00:00:01,620
        line1 some text
        """)
    }
}


