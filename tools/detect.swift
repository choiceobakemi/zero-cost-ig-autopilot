// Finds every line of text and every QR/barcode in an image using Apple's Vision framework.
// Tall images are processed in overlapping tiles so small text isn't lost.
// Build:  swiftc -O tools/detect.swift -o tools/detect
// Usage:  tools/detect image.png   -> one JSON object per line:
//         {"kind":"text"|"qr","text":"...","x":..,"y":..,"w":..,"h":..}  (pixels, top-left origin)
import Foundation
import Vision
import AppKit

let path = CommandLine.arguments[1]
guard let ns = NSImage(contentsOfFile: path),
      let full = ns.cgImage(forProposedRect: nil, context: nil, hints: nil) else { exit(1) }
let W = full.width, H = full.height
let tile = 3000, overlap = 300

func emit(_ kind: String, _ text: String, _ r: CGRect, _ ty: Int, _ th: Int) {
    let x = r.minX * CGFloat(W), w = r.width * CGFloat(W)
    let h = r.height * CGFloat(th), y = CGFloat(ty) + (1 - r.maxY) * CGFloat(th)
    let obj: [String: Any] = ["kind": kind, "text": text, "x": Int(x), "y": Int(y), "w": Int(w), "h": Int(h)]
    let d = try! JSONSerialization.data(withJSONObject: obj)
    print(String(data: d, encoding: .utf8)!)
}

var y0 = 0
while y0 < H {
    let th = min(tile, H - y0)
    let crop = full.cropping(to: CGRect(x: 0, y: y0, width: W, height: th))!
    let textReq = VNRecognizeTextRequest()
    textReq.recognitionLevel = .accurate
    textReq.recognitionLanguages = ["en-US", "ru-RU"]   // add your languages here
    let qrReq = VNDetectBarcodesRequest()
    try? VNImageRequestHandler(cgImage: crop).perform([textReq, qrReq])
    for o in textReq.results ?? [] { if let c = o.topCandidates(1).first { emit("text", c.string, o.boundingBox, y0, th) } }
    for o in qrReq.results ?? [] { emit("qr", o.payloadStringValue ?? "", o.boundingBox, y0, th) }
    if y0 + th >= H { break }
    y0 += tile - overlap
}
