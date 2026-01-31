import Foundation

/// アプリ全体のReducer
public enum AppReducer {
    /// 状態を更新する純粋関数
    public static func reduce(state: inout AppState, action: AppAction) {
        switch action {
        case .boot:
            // 起動時の状態変更なし（副作用でcheckICloudStatusまたはrestoreSessionを呼ぶ）
            break

        case .auth(let authAction):
            AuthReducer.reduce(state: &state.auth, action: authAction)
            // 認証状態に応じてScreenStateを更新
            handleAuthScreenStateTransition(state: &state, action: authAction)

        case .schedule(let scheduleAction):
            ScheduleReducer.reduce(state: &state.schedule, action: scheduleAction)

        case .home(let homeAction):
            HomeReducer.reduce(state: &state.home, action: homeAction)

        case .sharing(let sharingAction):
            SharingReducer.reduce(state: &state.sharing, action: sharingAction)

        case .assignment(let assignmentAction):
            AssignmentReducer.reduce(state: &state.assignment, action: assignmentAction)

        case .myAssignments(let myAssignmentsAction):
            MyAssignmentsReducer.reduce(state: &state.myAssignments, action: myAssignmentsAction)

        case .recipe(let recipeAction):
            RecipeReducer.reduce(state: &state.recipe, action: recipeAction)

        case .shoppingList(let shoppingListAction):
            ShoppingListReducer.reduce(state: &state.shoppingList, action: shoppingListAction)

        case .subscription(let subscriptionAction):
            SubscriptionReducer.reduce(state: &state.subscription, action: subscriptionAction)

        case .setScreenState(let screenState):
            state.screenState = screenState
        }
    }

    // MARK: - Private Helpers

    private static func handleAuthScreenStateTransition(state: inout AppState, action: AuthAction) {
        switch action {
        case .sessionRestored(let userID):
            if let userID = userID {
                // 認証済み — userIDを保存するのみ
                // 画面遷移はAppStoreの副作用で行う（loadUserData後）
                state.auth.authenticatedUserID = userID
            } else {
                // 未認証 → ログイン画面
                state.screenState = .login
            }

        case .otpSent(let email):
            state.screenState = .otpVerification(email: email)

        case .otpVerified(let userID, _):
            // userIDを保存するのみ
            // 画面遷移はAppStoreの副作用で行う（isNewUserに応じて）
            state.auth.authenticatedUserID = userID

        case .userDataLoaded(let profile, let groups):
            // Supabase: プロフィールとグループをScheduleStateに反映
            if let profile = profile {
                // SupabaseプロフィールからUserを作成（iCloudUserIDは空）
                let user = User(
                    id: profile.id,
                    iCloudUserID: "",
                    displayName: profile.displayName
                )
                state.schedule.currentUser = user
            }
            // グループがあれば最初のグループを選択
            if let firstGroup = groups.first {
                // SupabaseUserGroupからUserGroupを作成
                let userGroup = UserGroup(
                    id: firstGroup.id,
                    name: firstGroup.name
                )
                state.schedule.currentGroup = userGroup
                state.schedule.isGroupOwner = firstGroup.ownerID == state.auth.authenticatedUserID
            }
            // 画面遷移はAppStoreの副作用で行う

        case .loggedOut:
            state.screenState = .login
            state.auth.authenticatedUserID = nil
            state.schedule.currentUser = nil
            state.schedule.currentGroup = nil

        default:
            // その他のアクションではScreenStateを変更しない
            break
        }
    }
}
