import Testing
import UIKit
@testable import AppCore

@Suite
struct ImageSourceTests {

    // MARK: - Equality Tests (remote)

    @Test
    func remote_sameURL_isEqual() {
        let url = URL(string: "https://example.com/image.jpg")!
        let source1 = ImageSource.remote(url: url)
        let source2 = ImageSource.remote(url: url)
        #expect(source1 == source2)
    }

    @Test
    func remote_differentURL_isNotEqual() {
        let source1 = ImageSource.remote(url: URL(string: "https://example.com/a.jpg")!)
        let source2 = ImageSource.remote(url: URL(string: "https://example.com/b.jpg")!)
        #expect(source1 != source2)
    }

    // MARK: - Equality Tests (local)

    @Test
    func local_sameFileURL_isEqual() {
        let fileURL = URL(fileURLWithPath: "/tmp/test.jpg")
        let source1 = ImageSource.local(fileURL: fileURL)
        let source2 = ImageSource.local(fileURL: fileURL)
        #expect(source1 == source2)
    }

    @Test
    func local_differentFileURL_isNotEqual() {
        let source1 = ImageSource.local(fileURL: URL(fileURLWithPath: "/tmp/a.jpg"))
        let source2 = ImageSource.local(fileURL: URL(fileURLWithPath: "/tmp/b.jpg"))
        #expect(source1 != source2)
    }

    // MARK: - Equality Tests (uiImage - reference comparison)

    @Test
    func uiImage_sameInstance_isEqual() {
        let image = UIImage()
        let source1 = ImageSource.uiImage(image)
        let source2 = ImageSource.uiImage(image)
        #expect(source1 == source2)
    }

    @Test
    func uiImage_differentInstance_isNotEqual() {
        // 同じ内容でも異なるインスタンスなら非等価（参照比較）
        let image1 = UIImage()
        let image2 = UIImage()
        let source1 = ImageSource.uiImage(image1)
        let source2 = ImageSource.uiImage(image2)
        #expect(source1 != source2)
    }

    // MARK: - Cross-case Equality Tests

    @Test
    func remote_and_local_isNotEqual() {
        let url = URL(string: "https://example.com/image.jpg")!
        let fileURL = URL(fileURLWithPath: "/tmp/image.jpg")
        let remote = ImageSource.remote(url: url)
        let local = ImageSource.local(fileURL: fileURL)
        #expect(remote != local)
    }

    @Test
    func remote_and_uiImage_isNotEqual() {
        let url = URL(string: "https://example.com/image.jpg")!
        let remote = ImageSource.remote(url: url)
        let uiImage = ImageSource.uiImage(UIImage())
        #expect(remote != uiImage)
    }

    // MARK: - previewPlaceholder Tests

    @Test
    func previewPlaceholder_returnsUIImageCase() {
        let placeholder = ImageSource.previewPlaceholder()
        if case .uiImage = placeholder {
            // OK
        } else {
            Issue.record("previewPlaceholder should return .uiImage case")
        }
    }

    @Test
    func previewPlaceholder_defaultArguments_returnsCachedInstance() {
        // デフォルト引数で呼び出した場合、同じキャッシュインスタンスを返す
        let placeholder1 = ImageSource.previewPlaceholder()
        let placeholder2 = ImageSource.previewPlaceholder()
        #expect(placeholder1 == placeholder2)
    }

    @Test
    func previewPlaceholder_customArguments_returnsNewInstance() {
        // カスタム引数の場合は毎回新しいインスタンス
        let placeholder1 = ImageSource.previewPlaceholder(color: .red, size: CGSize(width: 100, height: 100))
        let placeholder2 = ImageSource.previewPlaceholder(color: .red, size: CGSize(width: 100, height: 100))
        #expect(placeholder1 != placeholder2)
    }
}
