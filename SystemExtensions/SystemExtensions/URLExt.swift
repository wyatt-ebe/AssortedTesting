//
//  URLExt.swift
//  SystemExtensions
//
//  Created by Wyatt Eberspacher on 6/24/21.
//

import UIKit
import AVFoundation

extension URL {
  /// If this url links to a video, extracts the first image.
  public func getThumbnail() -> UIImage? {
    let imageGenerator = AVAssetImageGenerator(asset: AVURLAsset(url: self))
    guard let cgImage = try? imageGenerator.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil) else { return nil }
    return UIImage(cgImage: cgImage)
  }
}
