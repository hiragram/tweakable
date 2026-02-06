#if DEBUG
import Testing
@testable import AppCore

@Suite
struct DebugReducerTests {

    // MARK: - Store Switching

    @Test
    func reduce_switchStore_setsProcessingTrue() {
        var state = DebugState()

        DebugReducer.reduce(state: &state, action: .switchStore(useTestStore: false))

        #expect(state.isProcessing == true)
    }

    @Test
    func reduce_switchStore_clearsErrorMessage() {
        var state = DebugState()
        state.errorMessage = "Previous error"

        DebugReducer.reduce(state: &state, action: .switchStore(useTestStore: false))

        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_switchStore_updatesCurrentStore() {
        var state = DebugState()
        state.currentStore = .testStore

        DebugReducer.reduce(state: &state, action: .switchStore(useTestStore: false))

        #expect(state.currentStore == .appStore)
    }

    @Test
    func reduce_storeSwitched_setsProcessingFalseAndRequiresRestart() {
        var state = DebugState()
        state.isProcessing = true

        DebugReducer.reduce(state: &state, action: .storeSwitched)

        #expect(state.isProcessing == false)
        #expect(state.requiresRestart == true)
    }

    // MARK: - User Reset

    @Test
    func reduce_resetUser_setsProcessingTrue() {
        var state = DebugState()

        DebugReducer.reduce(state: &state, action: .resetUser)

        #expect(state.isProcessing == true)
    }

    @Test
    func reduce_resetUser_clearsErrorMessage() {
        var state = DebugState()
        state.errorMessage = "Previous error"

        DebugReducer.reduce(state: &state, action: .resetUser)

        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_userReset_setsProcessingFalse() {
        var state = DebugState()
        state.isProcessing = true

        DebugReducer.reduce(state: &state, action: .userReset)

        #expect(state.isProcessing == false)
    }

    // MARK: - Data Deletion

    @Test
    func reduce_deleteAllData_setsProcessingTrue() {
        var state = DebugState()

        DebugReducer.reduce(state: &state, action: .deleteAllData)

        #expect(state.isProcessing == true)
    }

    @Test
    func reduce_deleteAllData_clearsErrorMessage() {
        var state = DebugState()
        state.errorMessage = "Previous error"

        DebugReducer.reduce(state: &state, action: .deleteAllData)

        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_dataDeleted_setsProcessingFalse() {
        var state = DebugState()
        state.isProcessing = true

        DebugReducer.reduce(state: &state, action: .dataDeleted)

        #expect(state.isProcessing == false)
    }

    // MARK: - Error Handling

    @Test
    func reduce_operationFailed_setsErrorMessage() {
        var state = DebugState()
        state.isProcessing = true

        DebugReducer.reduce(state: &state, action: .operationFailed("Something went wrong"))

        #expect(state.isProcessing == false)
        #expect(state.errorMessage == "Something went wrong")
    }

    @Test
    func reduce_clearError_clearsErrorMessage() {
        var state = DebugState()
        state.errorMessage = "Some error"

        DebugReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }
}
#endif
