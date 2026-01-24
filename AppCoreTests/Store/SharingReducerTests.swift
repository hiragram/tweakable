import Testing
import Foundation
import CloudKit
@testable import AppCore

@Suite
struct SharingReducerTests {

    // MARK: - Share Creation Tests

    @Test
    func reduce_startCreatingShare_setsIsCreatingShareToTrue() {
        // Arrange
        var state = SharingState()

        // Act
        SharingReducer.reduce(state: &state, action: .startCreatingShare)

        // Assert
        #expect(state.isCreatingShare == true)
    }

    @Test
    func reduce_shareCreated_setsShareURLAndClearsCreating() {
        // Arrange
        var state = SharingState()
        state.isCreatingShare = true
        let shareURL = URL(string: "https://www.icloud.com/share/test123")!

        // Act
        SharingReducer.reduce(state: &state, action: .shareCreated(url: shareURL))

        // Assert
        #expect(state.shareURL == shareURL)
        #expect(state.isCreatingShare == false)
    }

    @Test
    func reduce_shareCreationFailed_setsErrorAndClearsCreating() {
        // Arrange
        var state = SharingState()
        state.isCreatingShare = true

        // Act
        SharingReducer.reduce(state: &state, action: .shareCreationFailed(error: "テストエラー"))

        // Assert
        #expect(state.sharingError == "テストエラー")
        #expect(state.isCreatingShare == false)
    }

    // MARK: - Share Acceptance Tests

    @Test
    func reduce_startAcceptingShare_setsIsAcceptingShareToTrue() {
        // Arrange
        var state = SharingState()

        // Act
        SharingReducer.reduce(state: &state, action: .startAcceptingShare)

        // Assert
        #expect(state.isAcceptingShare == true)
    }

    @Test
    func reduce_shareAccepted_setsSharedGroupAndClearsAccepting() {
        // Arrange
        var state = SharingState()
        state.isAcceptingShare = true
        let group = UserGroup(name: "共有された家族")

        // Act
        SharingReducer.reduce(state: &state, action: .shareAccepted(group: group))

        // Assert
        #expect(state.sharedGroup?.name == "共有された家族")
        #expect(state.isAcceptingShare == false)
        #expect(state.hasJoinedSharedGroup == true)
    }

    @Test
    func reduce_shareAcceptanceFailed_setsErrorAndClearsAccepting() {
        // Arrange
        var state = SharingState()
        state.isAcceptingShare = true

        // Act
        SharingReducer.reduce(state: &state, action: .shareAcceptanceFailed(error: "受け入れエラー"))

        // Assert
        #expect(state.sharingError == "受け入れエラー")
        #expect(state.isAcceptingShare == false)
    }

    // MARK: - Clear Error Tests

    @Test
    func reduce_clearError_clearsError() {
        // Arrange
        var state = SharingState()
        state.sharingError = "何かのエラー"

        // Act
        SharingReducer.reduce(state: &state, action: .clearError)

        // Assert
        #expect(state.sharingError == nil)
    }

    // MARK: - Invitation State Tests

    @Test
    func reduce_startCreatingShare_setsInvitationStateToCreating() {
        // Arrange
        var state = SharingState()
        state.invitationState = .idle

        // Act
        SharingReducer.reduce(state: &state, action: .startCreatingShare)

        // Assert
        #expect(state.invitationState == .creating)
    }

    @Test
    func reduce_shareCreated_setsInvitationStateToSuccess() {
        // Arrange
        var state = SharingState()
        state.invitationState = .creating
        let shareURL = URL(string: "https://www.icloud.com/share/test123")!

        // Act
        SharingReducer.reduce(state: &state, action: .shareCreated(url: shareURL))

        // Assert
        #expect(state.invitationState == .success(url: shareURL))
    }

    @Test
    func reduce_shareCreationFailed_setsInvitationStateToError() {
        // Arrange
        var state = SharingState()
        state.invitationState = .creating

        // Act
        SharingReducer.reduce(state: &state, action: .shareCreationFailed(error: "エラーメッセージ"))

        // Assert
        #expect(state.invitationState == .error(message: "エラーメッセージ"))
    }

    @Test
    func reduce_resetInvitation_resetsInvitationStateToIdle() {
        // Arrange
        var state = SharingState()
        state.invitationState = .success(url: URL(string: "https://example.com")!)

        // Act
        SharingReducer.reduce(state: &state, action: .resetInvitation)

        // Assert
        #expect(state.invitationState == .idle)
        #expect(state.shareURL == nil)
    }

    // MARK: - Accept Invitation State Tests

    @Test
    func reduce_setInvitationInfo_setsInvitationInfoAndPendingState() {
        // Arrange
        var state = SharingState()
        let info = InvitationInfo(inviterName: "田中", groupName: "山田家")

        // Act
        SharingReducer.reduce(state: &state, action: .setInvitationInfo(info))

        // Assert
        #expect(state.pendingInvitationInfo == info)
        #expect(state.acceptInvitationState == .pending)
    }

    @Test
    func reduce_startAcceptingShare_setsAcceptStateToAccepting() {
        // Arrange
        var state = SharingState()
        state.acceptInvitationState = .pending

        // Act
        SharingReducer.reduce(state: &state, action: .startAcceptingShare)

        // Assert
        #expect(state.acceptInvitationState == .accepting)
    }

    @Test
    func reduce_shareAccepted_setsAcceptStateToSuccess() {
        // Arrange
        var state = SharingState()
        state.acceptInvitationState = .accepting
        let group = UserGroup(name: "共有グループ")

        // Act
        SharingReducer.reduce(state: &state, action: .shareAccepted(group: group))

        // Assert
        #expect(state.acceptInvitationState == .success)
        #expect(state.sharedGroup?.name == "共有グループ")
    }

    @Test
    func reduce_shareAcceptanceFailed_setsAcceptStateToError() {
        // Arrange
        var state = SharingState()
        state.acceptInvitationState = .accepting

        // Act
        SharingReducer.reduce(state: &state, action: .shareAcceptanceFailed(error: "エラー"))

        // Assert
        #expect(state.acceptInvitationState == .error(message: "エラー"))
    }

    @Test
    func reduce_resetAcceptInvitation_resetsAcceptState() {
        // Arrange
        var state = SharingState()
        state.acceptInvitationState = .success
        state.pendingInvitationInfo = InvitationInfo(inviterName: "田中", groupName: "山田家")

        // Act
        SharingReducer.reduce(state: &state, action: .resetAcceptInvitation)

        // Assert
        #expect(state.acceptInvitationState == .idle)
        #expect(state.pendingInvitationInfo == nil)
    }

    // MARK: - Join Request Management Tests (Owner side)

    @Test
    func reduce_setPendingJoinRequests_setsRequests() {
        // Arrange
        var state = SharingState()
        let request1 = JoinRequest(
            participantID: "participant-1",
            userName: "田中太郎"
        )
        let request2 = JoinRequest(
            participantID: "participant-2",
            userName: "佐藤花子"
        )

        // Act
        SharingReducer.reduce(state: &state, action: .setPendingJoinRequests([request1, request2]))

        // Assert
        #expect(state.pendingJoinRequests.count == 2)
        #expect(state.pendingJoinRequests[0].userName == "田中太郎")
        #expect(state.pendingJoinRequests[1].userName == "佐藤花子")
    }

    @Test
    func reduce_startApprovingRequest_setsProcessingState() {
        // Arrange
        var state = SharingState()
        let participantID = "test-participant-id"

        // Act
        SharingReducer.reduce(state: &state, action: .startApprovingRequest(participantID: participantID))

        // Assert
        #expect(state.processingRequestID == participantID)
    }

    @Test
    func reduce_requestApproved_removesRequestFromList() {
        // Arrange
        var state = SharingState()
        let participantID = "test-participant-id"
        let request = JoinRequest(
            participantID: participantID,
            userName: "田中太郎"
        )
        state.pendingJoinRequests = [request]
        state.processingRequestID = participantID

        // Act
        SharingReducer.reduce(state: &state, action: .requestApproved(participantID: participantID))

        // Assert
        #expect(state.pendingJoinRequests.isEmpty)
        #expect(state.processingRequestID == nil)
    }

    @Test
    func reduce_startRejectingRequest_setsProcessingState() {
        // Arrange
        var state = SharingState()
        let participantID = "test-participant-id"

        // Act
        SharingReducer.reduce(state: &state, action: .startRejectingRequest(participantID: participantID))

        // Assert
        #expect(state.processingRequestID == participantID)
    }

    @Test
    func reduce_requestRejected_removesRequestFromList() {
        // Arrange
        var state = SharingState()
        let participantID = "test-participant-id"
        let request = JoinRequest(
            participantID: participantID,
            userName: "田中太郎"
        )
        state.pendingJoinRequests = [request]
        state.processingRequestID = participantID

        // Act
        SharingReducer.reduce(state: &state, action: .requestRejected(participantID: participantID))

        // Assert
        #expect(state.pendingJoinRequests.isEmpty)
        #expect(state.processingRequestID == nil)
    }

    @Test
    func reduce_requestProcessingFailed_clearsProcessingState() {
        // Arrange
        var state = SharingState()
        let participantID = "test-participant-id"
        state.processingRequestID = participantID

        // Act
        SharingReducer.reduce(state: &state, action: .requestProcessingFailed(error: "処理に失敗しました"))

        // Assert
        #expect(state.processingRequestID == nil)
        #expect(state.sharingError == "処理に失敗しました")
    }

    // MARK: - Member List Tests

    @Test
    func reduce_startLoadingMembers_setsIsLoadingMembersToTrue() {
        // Arrange
        var state = SharingState()

        // Act
        SharingReducer.reduce(state: &state, action: .startLoadingMembers)

        // Assert
        #expect(state.isLoadingMembers == true)
    }

    @Test
    func reduce_setMembers_setsMembersAndClearsLoading() {
        // Arrange
        var state = SharingState()
        state.isLoadingMembers = true
        let member1 = GroupMember(
            participantID: "owner-id",
            displayName: "オーナー",
            isOwner: true
        )
        let member2 = GroupMember(
            participantID: "member-id",
            displayName: "田中太郎",
            isOwner: false
        )

        // Act
        SharingReducer.reduce(state: &state, action: .setMembers([member1, member2]))

        // Assert
        #expect(state.members.count == 2)
        #expect(state.members[0].displayName == "オーナー")
        #expect(state.members[0].isOwner == true)
        #expect(state.members[1].displayName == "田中太郎")
        #expect(state.members[1].isOwner == false)
        #expect(state.isLoadingMembers == false)
    }

    @Test
    func reduce_loadMembersFailed_setsErrorAndClearsLoading() {
        // Arrange
        var state = SharingState()
        state.isLoadingMembers = true

        // Act
        SharingReducer.reduce(state: &state, action: .loadMembersFailed(error: "メンバー取得エラー"))

        // Assert
        #expect(state.isLoadingMembers == false)
        #expect(state.sharingError == "メンバー取得エラー")
    }

    // MARK: - Approval Status Tests

    @Test
    func reduce_setApprovalStatus_setsIsApprovedMember() {
        // Arrange
        var state = SharingState()
        state.isApprovedMember = false

        // Act
        SharingReducer.reduce(state: &state, action: .setApprovalStatus(isApproved: true))

        // Assert
        #expect(state.isApprovedMember == true)
    }

    @Test
    func reduce_checkApprovalStatus_setsIsCheckingToTrue() {
        // Arrange
        var state = SharingState()
        state.isCheckingApprovalStatus = false

        // Act
        SharingReducer.reduce(state: &state, action: .checkApprovalStatus)

        // Assert
        #expect(state.isCheckingApprovalStatus == true)
    }

    @Test
    func reduce_setApprovalStatus_approved_setsIsApprovedAndClearsChecking() {
        // Arrange
        var state = SharingState()
        state.isCheckingApprovalStatus = true
        state.isApprovedMember = false

        // Act
        SharingReducer.reduce(state: &state, action: .setApprovalStatus(isApproved: true))

        // Assert
        #expect(state.isApprovedMember == true)
        #expect(state.isCheckingApprovalStatus == false)
    }

    @Test
    func reduce_setApprovalStatus_notApproved_setsIsNotApprovedAndClearsChecking() {
        // Arrange
        var state = SharingState()
        state.isCheckingApprovalStatus = true
        state.isApprovedMember = true

        // Act
        SharingReducer.reduce(state: &state, action: .setApprovalStatus(isApproved: false))

        // Assert
        #expect(state.isApprovedMember == false)
        #expect(state.isCheckingApprovalStatus == false)
    }

    @Test
    func reduce_shareAcceptanceFailed_clearsCheckingApprovalStatus() {
        // Arrange
        var state = SharingState()
        state.isCheckingApprovalStatus = true

        // Act
        SharingReducer.reduce(state: &state, action: .shareAcceptanceFailed(error: "テストエラー"))

        // Assert
        #expect(state.isCheckingApprovalStatus == false)
        #expect(state.sharingError == "テストエラー")
    }

    // MARK: - Invite Code Tests (Supabase)

    @Test
    func reduce_startCreatingInviteCode_setsIsCreatingInviteCodeToTrue() {
        // Arrange
        var state = SharingState()

        // Act
        SharingReducer.reduce(state: &state, action: .startCreatingInviteCode)

        // Assert
        #expect(state.isCreatingInviteCode == true)
    }

    @Test
    func reduce_inviteCodeCreated_setsInviteCodeAndClearsCreating() {
        // Arrange
        var state = SharingState()
        state.isCreatingInviteCode = true

        // Act
        SharingReducer.reduce(state: &state, action: .inviteCodeCreated(code: "ABC123"))

        // Assert
        #expect(state.generatedInviteCode == "ABC123")
        #expect(state.isCreatingInviteCode == false)
    }

    @Test
    func reduce_inviteCodeCreationFailed_setsErrorAndClearsCreating() {
        // Arrange
        var state = SharingState()
        state.isCreatingInviteCode = true

        // Act
        SharingReducer.reduce(state: &state, action: .inviteCodeCreationFailed(error: "コード生成エラー"))

        // Assert
        #expect(state.sharingError == "コード生成エラー")
        #expect(state.isCreatingInviteCode == false)
    }

    @Test
    func reduce_setInviteCodeInput_setsInputCode() {
        // Arrange
        var state = SharingState()

        // Act
        SharingReducer.reduce(state: &state, action: .setInviteCodeInput("XYZ789"))

        // Assert
        #expect(state.inviteCodeInput == "XYZ789")
    }

    @Test
    func reduce_startJoiningWithCode_setsIsJoiningToTrue() {
        // Arrange
        var state = SharingState()
        state.inviteCodeInput = "ABC123"

        // Act
        SharingReducer.reduce(state: &state, action: .startJoiningWithCode)

        // Assert
        #expect(state.isJoiningWithCode == true)
    }

    @Test
    func reduce_joinedWithCode_setsGroupAndClearsJoining() {
        // Arrange
        var state = SharingState()
        state.isJoiningWithCode = true
        state.inviteCodeInput = "ABC123"
        let group = SupabaseUserGroup(id: UUID(), name: "テストグループ", ownerID: UUID())

        // Act
        SharingReducer.reduce(state: &state, action: .joinedWithCode(group: group))

        // Assert
        #expect(state.joinedSupabaseGroup?.name == "テストグループ")
        #expect(state.isJoiningWithCode == false)
        #expect(state.inviteCodeInput == "")
    }

    @Test
    func reduce_joinWithCodeFailed_setsErrorAndClearsJoining() {
        // Arrange
        var state = SharingState()
        state.isJoiningWithCode = true

        // Act
        SharingReducer.reduce(state: &state, action: .joinWithCodeFailed(error: "無効なコード"))

        // Assert
        #expect(state.sharingError == "無効なコード")
        #expect(state.isJoiningWithCode == false)
    }

    @Test
    func reduce_clearGeneratedInviteCode_clearsCode() {
        // Arrange
        var state = SharingState()
        state.generatedInviteCode = "ABC123"

        // Act
        SharingReducer.reduce(state: &state, action: .clearGeneratedInviteCode)

        // Assert
        #expect(state.generatedInviteCode == nil)
    }

    @Test
    func reduce_resetInviteCodeState_resetsAllInviteCodeRelatedState() {
        // Arrange
        var state = SharingState()
        state.isCreatingInviteCode = true
        state.generatedInviteCode = "ABC123"
        state.inviteCodeInput = "XYZ789"
        state.isJoiningWithCode = true
        state.joinedSupabaseGroup = SupabaseUserGroup(id: UUID(), name: "テスト", ownerID: UUID())
        state.sharingError = "エラー"

        // Act
        SharingReducer.reduce(state: &state, action: .resetInviteCodeState)

        // Assert
        #expect(state.isCreatingInviteCode == false)
        #expect(state.generatedInviteCode == nil)
        #expect(state.inviteCodeInput == "")
        #expect(state.isJoiningWithCode == false)
        #expect(state.joinedSupabaseGroup == nil)
        #expect(state.sharingError == nil)
    }
}
