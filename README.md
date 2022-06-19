# SrtProcess

`SrtProcess` is a Swift Package which you can use to parse `SRT` (`SubRip` file format).

Usage:

```swift
let srt = """
1
00:00:00,720 --> 00:00:01,620
line1 some text
"""
let nodes = try! srt.srtNodes()
print(nodes)
// [SrtProcess.SrtProcess.SrtNode(index: 1, 
//                                interval: SrtProcess.SrtProcess.SrtInterval(
//                                      start: SrtProcess.SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 0, milliseconds: 720), 
//                                      end: SrtProcess.SrtProcess.SrtTime(hours: 0, minutes: 0, seconds: 1, milliseconds: 620)), 
//                                text: "line1 some text")]
```

## References

- [GitHub | ggoraa - SubtitleKit](https://github.com/ggoraa/SubtitleKit)
- https://www.advancedswift.com/regex-capture-groups/
