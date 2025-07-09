import NMapsMap

internal struct NOverlayImage {
    let path: String
    let mode: NOverlayImageMode

    var overlayImage: NMFOverlayImage {
        switch mode {
        case .file, .temp, .widget: return makeOverlayImageWithPath()
        case .asset: return makeOverlayImageWithAssetPath()
        }
    }

    private func makeOverlayImageWithPath() -> NMFOverlayImage {
        guard let image = UIImage(contentsOfFile: path) else {
            print("⚠️ NOverlayImage: 이미지 파일을 찾을 수 없음: \(path)")
            // fallback: 투명 1x1 이미지 등으로 대체
            let fallback = UIImage(color: UIColor.clear, size: CGSize(width: 1, height: 1))
            return NMFOverlayImage(image: fallback)
        }
        guard let pngData = image.pngData(),
            let scaledImage = UIImage(data: pngData, scale: UIScreen.main.scale) else {
            print("⚠️ NOverlayImage: 이미지 변환 실패: \(path)")
            let fallback = UIImage(color: UIColor.clear, size: CGSize(width: 1, height: 1))
            return NMFOverlayImage(image: fallback)
        }
        return NMFOverlayImage(image: scaledImage)
    }

    private func makeOverlayImageWithAssetPath() -> NMFOverlayImage {
        let key = SwiftFlutterNaverMapPlugin.getAssets(path: path)
        let assetPath = Bundle.main.path(forResource: key, ofType: nil) ?? ""
        let image = UIImage(contentsOfFile: assetPath)
        let scaledImage = UIImage(data: image!.pngData()!, scale: UIScreen.main.scale)
        let overlayImg = NMFOverlayImage(image: scaledImage!, reuseIdentifier: assetPath)
        return overlayImg
    }

    func toMessageable() -> Dictionary<String, Any> {
        [
            "path": path,
            "mode": mode.rawValue
        ]
    }

    static func fromMessageable(_ v: Any) -> NOverlayImage {
        let d = asDict(v)
        return NOverlayImage(
                path: asString(d["path"]!),
                mode: NOverlayImageMode(rawValue: asString(d["mode"]!))!
        )
    }

    static let none = NOverlayImage(path: "", mode: .temp)
}
