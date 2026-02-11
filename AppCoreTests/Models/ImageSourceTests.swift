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

    // MARK: - Equality Tests (bundled)

    @Test
    func bundled_sameName_isEqual() {
        let source1 = ImageSource.bundled(name: "seed-shakshuka")
        let source2 = ImageSource.bundled(name: "seed-shakshuka")
        #expect(source1 == source2)
    }

    @Test
    func bundled_differentName_isNotEqual() {
        let source1 = ImageSource.bundled(name: "seed-shakshuka")
        let source2 = ImageSource.bundled(name: "seed-chicken-tikka")
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

    @Test
    func bundled_and_remote_isNotEqual() {
        let bundled = ImageSource.bundled(name: "seed-shakshuka")
        let remote = ImageSource.remote(url: URL(string: "https://example.com/image.jpg")!)
        #expect(bundled != remote)
    }

    @Test
    func bundled_and_uiImage_isNotEqual() {
        let bundled = ImageSource.bundled(name: "seed-shakshuka")
        let uiImage = ImageSource.uiImage(UIImage())
        #expect(bundled != uiImage)
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

    // MARK: - Persistence Tests

    @Test
    func toPersistenceString_remote_returnsAbsoluteString() {
        let source = ImageSource.remote(url: URL(string: "https://example.com/image.jpg")!)
        #expect(source.toPersistenceString() == "https://example.com/image.jpg")
    }

    @Test
    func toPersistenceString_bundled_returnsPrefixedName() {
        let source = ImageSource.bundled(name: "seed-shakshuka")
        #expect(source.toPersistenceString() == "bundled://seed-shakshuka")
    }

    @Test
    func toPersistenceString_local_returnsNil() {
        let source = ImageSource.local(fileURL: URL(fileURLWithPath: "/tmp/test.jpg"))
        #expect(source.toPersistenceString() == nil)
    }

    @Test
    func toPersistenceString_uiImage_returnsNil() {
        let source = ImageSource.uiImage(UIImage())
        #expect(source.toPersistenceString() == nil)
    }

    @Test
    func fromPersistenceString_remote_returnsRemoteCase() {
        let result = ImageSource.fromPersistenceString("https://example.com/image.jpg")
        if case .remote(let url) = result {
            #expect(url.absoluteString == "https://example.com/image.jpg")
        } else {
            Issue.record("Expected .remote case")
        }
    }

    @Test
    func fromPersistenceString_bundled_returnsBundledCase() {
        let result = ImageSource.fromPersistenceString("bundled://seed-shakshuka")
        if case .bundled(let name) = result {
            #expect(name == "seed-shakshuka")
        } else {
            Issue.record("Expected .bundled case")
        }
    }

    @Test
    func fromPersistenceString_emptyString_returnsNil() {
        let result = ImageSource.fromPersistenceString("")
        #expect(result == nil)
    }

    @Test
    func fromPersistenceString_bundledPrefixOnly_returnsEmptyName() {
        let result = ImageSource.fromPersistenceString("bundled://")
        if case .bundled(let name) = result {
            #expect(name == "")
        } else {
            Issue.record("Expected .bundled case with empty name")
        }
    }

    @Test
    func fromPersistenceString_nonBundledString_returnsRemoteIfValidURL() {
        // URL(string:) は多くの文字列を有効なURLとして受け入れるため、
        // bundled://以外の文字列はremoteとして扱われる
        let result = ImageSource.fromPersistenceString("https://example.com/photo.png")
        if case .remote(let url) = result {
            #expect(url.absoluteString == "https://example.com/photo.png")
        } else {
            Issue.record("Expected .remote case")
        }
    }

    @Test
    func persistence_roundTrip_remote() {
        let original = ImageSource.remote(url: URL(string: "https://example.com/image.jpg")!)
        let string = original.toPersistenceString()!
        let restored = ImageSource.fromPersistenceString(string)
        #expect(original == restored)
    }

    @Test
    func persistence_roundTrip_bundled() {
        let original = ImageSource.bundled(name: "seed-shakshuka")
        let string = original.toPersistenceString()!
        let restored = ImageSource.fromPersistenceString(string)
        #expect(original == restored)
    }
}
