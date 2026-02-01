#if DEBUG
import Foundation

/// デバッグ機能のReducer
public enum DebugReducer {
    public static func reduce(state: inout DebugState, action: DebugAction) {
        switch action {
        case .switchStore(let useTestStore):
            state.isProcessing = true
            state.errorMessage = nil
            state.currentStore = useTestStore ? .testStore : .appStore

        case .storeSwitched:
            state.isProcessing = false
            state.requiresRestart = true

        case .resetUser:
            state.isProcessing = true
            state.errorMessage = nil

        case .userReset:
            state.isProcessing = false

        case .deleteAllData:
            state.isProcessing = true
            state.errorMessage = nil

        case .dataDeleted:
            state.isProcessing = false

        case .operationFailed(let message):
            state.isProcessing = false
            state.errorMessage = message

        case .clearError:
            state.errorMessage = nil
        }
    }
}
#endif
