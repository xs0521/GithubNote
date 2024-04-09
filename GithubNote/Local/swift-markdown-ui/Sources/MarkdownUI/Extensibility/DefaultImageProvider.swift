import NetworkImage
import SwiftUI

/// The default image provider, which loads images from the network.
public struct DefaultImageProvider: ImageProvider {
  public func makeImage(url: URL?) -> some View {
    NetworkImage(url: url) { state in
      switch state {
      case .empty:
          ProgressView()
      case .failure:
          Image(systemName: "xmark.octagon")
              .font(.system(size: 60))
              .symbolRenderingMode(.hierarchical)
      case .success(let image, let idealSize):
        ResizeToFit(idealSize: idealSize) {
          image.resizable()
        }
      }
    }
  }
}

extension ImageProvider where Self == DefaultImageProvider {
  /// The default image provider, which loads images from the network.
  ///
  /// Use the `markdownImageProvider(_:)` modifier to configure this image provider for a view hierarchy.
  public static var `default`: Self {
    .init()
  }
}
