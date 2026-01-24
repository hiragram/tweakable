import Foundation

extension Bundle {
    /// App.frameworkのバンドルを返す
    static var app: Bundle {
        Bundle(for: BundleToken.self)
    }
}

/// App.frameworkのバンドルを特定するためのプライベートクラス
private final class BundleToken {}
