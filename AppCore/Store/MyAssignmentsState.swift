import Foundation

/// 担当の種類（自分の担当一覧用）
public enum MyAssignmentType: String, Equatable, Sendable {
    case dropOff  // 送り
    case pickUp   // 迎え
}

/// 自分の担当アイテム（表示用）
public struct MyAssignmentItem: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let date: Date
    public let groupID: UUID
    public let groupName: String
    public let assignmentType: MyAssignmentType

    public init(
        id: UUID = UUID(),
        date: Date,
        groupID: UUID,
        groupName: String,
        assignmentType: MyAssignmentType
    ) {
        self.id = id
        self.date = date
        self.groupID = groupID
        self.groupName = groupName
        self.assignmentType = assignmentType
    }
}

/// 自分の担当一覧画面の状態
public struct MyAssignmentsState: Equatable, Sendable {
    /// 全グループから取得した自分の担当一覧（今日以降）
    public var myAssignments: [MyAssignmentItem] = []

    /// 読み込み中フラグ
    public var isLoading: Bool = false

    /// エラーメッセージ
    public var errorMessage: String?

    public init() {}
}
