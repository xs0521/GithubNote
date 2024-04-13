import SwiftUI
import SDWebImageSwiftUI

/// The default image provider, which loads images from the network.
public struct DefaultImageProvider: ImageProvider {
  public func makeImage(url: URL?) -> some View {
      WebImage(url: url) { image in
        image.resizable() // Control layout like SwiftUI.AsyncImage, you must use this modifier or the view will use the image bitmap size
      } placeholder: {
          ZStack {
              Rectangle().foregroundColor(Color(red: 225 / 255, green: 225 / 255, blue: 224 / 255))
                  .frame(maxWidth: .infinity, maxHeight: 70)
              Image(systemName: "photo")
                .font(.system(size: 40))
                .symbolRenderingMode(.hierarchical)
          }
          .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
      .onSuccess { image, data, cacheType in
          // Success
          // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
      }
      .onFailure(perform: { error in
          
      })
//      .indicator(.activity) // Activity Indicator
      .transition(.fade(duration: 0.5)) // Fade Transition with duration
      .scaledToFit()
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
