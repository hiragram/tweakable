import Foundation

/// スケジュール機能のReducer（純粋関数）
public enum ScheduleReducer {
    /// 状態を更新する純粋関数
    /// - Parameters:
    ///   - state: 現在の状態（inout）
    ///   - action: 実行するアクション
    public static func reduce(state: inout ScheduleState, action: ScheduleAction) {
        switch action {
        // MARK: - User Actions

        case .setupUser:
            // 副作用のみ（Storeで処理）
            break

        case .userSetupCompleted(let user):
            state.currentUser = user

        case .loadCurrentUser:
            // 副作用のみ（Storeで処理）
            break

        case .currentUserLoaded(let user):
            state.currentUser = user

        // MARK: - Group Actions

        case .createGroup:
            // 副作用のみ（Storeで処理）
            break

        case .groupCreated(let group):
            state.currentGroup = group
            state.isCreatingGroup = false
            // 複数グループ対応: 新規作成されたグループをgroups配列にも追加
            if !state.groups.contains(where: { $0.id == group.id }) {
                state.groups.append(group)
            }

        case .loadCurrentGroup:
            // 副作用のみ（Storeで処理）
            break

        case .currentGroupLoaded(let group):
            state.currentGroup = group

        case .setIsGroupOwner(let isOwner):
            state.isGroupOwner = isOwner

        // MARK: - Multiple Groups Actions

        case .loadGroups:
            // 副作用のみ（Storeで処理）
            break

        case .groupsLoaded(let groups):
            state.groups = groups

        case .selectGroup(let groupID):
            guard let group = state.groups.first(where: { $0.id == groupID }) else { return }
            state.currentGroup = group

        case .setGroupOwnership(let groupID, let isOwner):
            state.groupOwnership[groupID] = isOwner

        // MARK: - Schedule Actions

        case .initializeWeekSchedule(let weekStartDate):
            state.weekStartDate = weekStartDate
            guard let userID = state.currentUser?.id,
                  let userGroupID = state.currentGroup?.id else { return }

            let calendar = Calendar.current
            state.weekEntries = (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: weekStartDate) else {
                    return nil
                }
                return DayScheduleEntry(date: date, userID: userID, userGroupID: userGroupID)
            }

        case .loadWeekSchedule(let weekStartDate):
            state.weekStartDate = weekStartDate
            state.isLoading = true

        case .weekScheduleLoaded(let entries):
            state.isLoading = false
            if entries.isEmpty {
                // エントリがなければ初期化（副作用は別途）
            } else {
                state.weekEntries = mergeEntries(
                    existing: entries,
                    weekStartDate: state.weekStartDate,
                    userID: state.currentUser?.id,
                    userGroupID: state.currentGroup?.id
                )
            }

        case .updateEntry(let index, let dropOff, let pickUp):
            guard index < state.weekEntries.count else { return }

            if let dropOff = dropOff {
                state.weekEntries[index].dropOffStatus = dropOff
            }
            if let pickUp = pickUp {
                state.weekEntries[index].pickUpStatus = pickUp
            }

        case .submitSchedule:
            state.isSaving = true

        case .submitCompleted(let entries):
            state.isSaving = false
            state.weekEntries = entries

        // MARK: - Loading Actions

        case .setLoading(let isLoading):
            state.isLoading = isLoading

        case .setSaving(let isSaving):
            state.isSaving = isSaving

        // MARK: - Error Actions

        case .errorOccurred(let message):
            state.errorMessage = message
            state.isLoading = false
            state.isSaving = false

        case .clearError:
            state.errorMessage = nil

        // MARK: - UI Actions

        case .showSuccessToast:
            state.showSuccessToast = true

        case .hideSuccessToast:
            state.showSuccessToast = false

        // MARK: - Group Creation Actions

        case .startCreatingGroup:
            state.isCreatingGroup = true

        case .groupCreationFailed(let message):
            state.isCreatingGroup = false
            state.errorMessage = message

        // MARK: - Enabled Weekdays Actions

        case .updateEnabledWeekday(let weekday, let enabled):
            guard state.currentGroup != nil else { return }
            state.currentGroup?.enabledWeekdays[weekday] = enabled

        // MARK: - Group Deletion Actions

        case .deleteGroup:
            // 副作用のみ（Storeで処理）
            break

        case .setDeletingGroup(let isDeletingGroup):
            state.isDeletingGroup = isDeletingGroup

        case .groupDeleted(let groupID):
            state.isDeletingGroup = false
            // groups配列から削除
            state.groups.removeAll { $0.id == groupID }
            // groupOwnershipから削除
            state.groupOwnership.removeValue(forKey: groupID)
            // currentGroupが削除されたグループだった場合
            if state.currentGroup?.id == groupID {
                // 別のグループがあれば最初のものを選択
                state.currentGroup = state.groups.first
            }

        case .groupDeletionFailed(let message):
            state.isDeletingGroup = false
            state.errorMessage = message
        }
    }

    // MARK: - Private Helpers

    private static func mergeEntries(
        existing: [DayScheduleEntry],
        weekStartDate: Date,
        userID: UUID?,
        userGroupID: UUID?
    ) -> [DayScheduleEntry] {
        guard let userID = userID, let userGroupID = userGroupID else { return existing }

        let calendar = Calendar.current
        var result: [DayScheduleEntry] = []

        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStartDate) else {
                continue
            }

            if let existingEntry = existing.first(where: { $0.userID == userID && calendar.isDate($0.date, inSameDayAs: date) }) {
                result.append(existingEntry)
            } else {
                result.append(DayScheduleEntry(date: date, userID: userID, userGroupID: userGroupID))
            }
        }

        return result
    }
}
