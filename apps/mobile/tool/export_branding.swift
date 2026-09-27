#!/usr/bin/env swift
// Run on macOS from apps/mobile:
// swift -module-cache-path /tmp/vardigo-branding-modules tool/export_branding.swift
// Re-exports the approved PNG without changing its artwork. No packages needed.

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let root = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent()
let sourceURL = root.appendingPathComponent("assets/branding/vardigo_splash_logo.png")
guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
      let logo = CGImageSourceCreateImageAtIndex(source, 0, nil),
      let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
    fatalError("Cannot read branding source: \(sourceURL.path)")
}

func export(_ path: String, size: Int, artworkFraction: CGFloat = 1, opaque: Bool = false) throws {
    let alpha: CGImageAlphaInfo = opaque ? .noneSkipLast : .premultipliedLast
    guard let context = CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: size * 4, space: colorSpace,
        bitmapInfo: alpha.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
    ) else { fatalError("Cannot create \(size)px export context") }

    let canvas = CGRect(x: 0, y: 0, width: size, height: size)
    if opaque {
        context.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
        context.fill(canvas)
    } else {
        context.clear(canvas)
    }
    context.interpolationQuality = .high
    let extent = CGFloat(size) * artworkFraction
    let inset = (CGFloat(size) - extent) / 2
    context.draw(logo, in: CGRect(x: inset, y: inset, width: extent, height: extent))
    guard let image = context.makeImage() else { fatalError("Cannot create export image") }

    let target = root.appendingPathComponent(path)
    try FileManager.default.createDirectory(
        at: target.deletingLastPathComponent(), withIntermediateDirectories: true
    )
    guard let destination = CGImageDestinationCreateWithURL(
        target as CFURL, UTType.png.identifier as CFString, 1, nil
    ) else { fatalError("Cannot write \(target.path)") }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Failed to export \(target.path)") }
    print(target.path.replacingOccurrences(of: root.path + "/", with: ""))
}

// The iOS catalog remains the source of truth for all required icon sizes.
let iconCatalog = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
let catalogData = try Data(contentsOf: root.appendingPathComponent("\(iconCatalog)/Contents.json"))
let catalog = try JSONSerialization.jsonObject(with: catalogData) as! [String: Any]
var exported = Set<String>()
for item in catalog["images"] as! [[String: String]] {
    guard let file = item["filename"], exported.insert(file).inserted else { continue }
    let points = Double(item["size"]!.components(separatedBy: "x")[0])!
    let scale = Double(item["scale"]!.replacingOccurrences(of: "x", with: ""))!
    // App Store icons require an opaque background. The source's own margin is retained.
    try export("\(iconCatalog)/\(file)", size: Int(points * scale), opaque: true)
}

for scale in 1...3 {
    let suffix = scale == 1 ? "" : "@\(scale)x"
    try export("ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage\(suffix).png", size: 220 * scale)
}

let android = "android/app/src/main/res"
for (density, scale) in [("mdpi", 1.0), ("hdpi", 1.5), ("xhdpi", 2.0), ("xxhdpi", 3.0), ("xxxhdpi", 4.0)] {
    try export("\(android)/mipmap-\(density)/ic_launcher.png", size: Int(48 * scale), opaque: true)
    // Adaptive icons expose a 66dp circular safe area in a 108dp canvas.
    // 60dp of source artwork keeps the complete wordmark inside every mask.
    try export("\(android)/drawable-\(density)/ic_launcher_foreground.png", size: Int(108 * scale), artworkFraction: 60 / 108)
    try export("\(android)/drawable-\(density)/launch_logo.png", size: Int(220 * scale))
    // Android 12+ masks its 288dp splash icon to a 192dp safe circle.
    try export("\(android)/drawable-\(density)/splash_icon.png", size: Int(288 * scale), artworkFraction: 176 / 288)
}
