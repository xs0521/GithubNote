import SwiftUI

final class NetworkImageModel: ObservableObject {
  struct Environment {
    let transaction: Transaction
    let imageLoader: NetworkImageLoader
  }

  struct State: Equatable {
    var source: ImageSource?
    var image: NetworkImageState = .empty
  }

  @Published private(set) var state: State = .init()

  @MainActor func onAppear(source: ImageSource?, environment: Environment) async {
    guard source != self.state.source else { return }

    guard let source else {
      self.state = .init()
      return
    }

    self.state.source = source

    let image: NetworkImageState

    do {
      let cgImage = try await environment.imageLoader.image(from: source.url)
      image = .success(
        image: .init(decorative: cgImage, scale: source.scale),
        idealSize: CGSize(
          width: CGFloat(cgImage.width) / source.scale,
          height: CGFloat(cgImage.height) / source.scale
        )
      )
    } catch {
      image = .failure
    }

    withTransaction(environment.transaction) {
      self.state.image = image
    }
  }
}
