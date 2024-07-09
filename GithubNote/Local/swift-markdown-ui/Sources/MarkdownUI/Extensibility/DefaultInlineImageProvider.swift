import SDWebImageSwiftUI
import SwiftUI

/// The default inline image provider, which loads images from the network.
public struct DefaultInlineImageProvider: InlineImageProvider {
  public func image(with url: URL, label: String) async throws -> Image {
      // Use WebImage to load image from url
      let webImage = await WebImage(url: url)
          .resizable()
//          .indicator(.activity) // Show activity indicator while loading
          .scaledToFit()
      // Convert WebImage to Image
      guard let webImage = webImage as? String else { return Image("photo") }
      let image = Image(decorative: webImage)
      return image
  }
}

extension InlineImageProvider where Self == DefaultInlineImageProvider {
  /// The default inline image provider, which loads images from the network.
  ///
  /// Use the `markdownInlineImageProvider(_:)` modifier to configure
  /// this image provider for a view hierarchy.
  public static var `default`: Self {
    .init()
  }
}
