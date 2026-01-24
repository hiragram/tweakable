import Foundation

/// 共有機能のReducer（純粋関数）
public enum SharingReducer {
    /// 状態をアクションに基づいて更新する（純粋関数）
    /// - Parameters:
    ///   - state: 現在の状態（inout）
    ///   - action: 実行するアクション
    public static func reduce(state: inout SharingState, action: SharingAction) {
        switch action {
        case .startCreatingShare:
            state.isCreatingShare = true
            state.invitationState = .creating

        case .shareCreated(let url):
            state.isCreatingShare = false
            state.shareURL = url
            state.invitationState = .success(url: url)

        case .shareCreationFailed(let error):
            state.isCreatingShare = false
            state.sharingError = error
            state.invitationState = .error(message: error)

        case .resetInvitation:
            state.invitationState = .idle
            state.shareURL = nil
            state.sharingError = nil

        case .setInvitationInfo(let info):
            state.pendingInvitationInfo = info
            state.acceptInvitationState = .pending

        case .startAcceptingShare:
            state.isAcceptingShare = true
            state.acceptInvitationState = .accepting

        case .shareAccepted(let group):
            state.isAcceptingShare = false
            state.sharedGroup = group
            state.hasJoinedSharedGroup = true
            state.acceptInvitationState = .success

        case .shareAcceptanceFailed(let error):
            state.isAcceptingShare = false
            state.sharingError = error
            state.acceptInvitationState = .error(message: error)
            state.isCheckingApprovalStatus = false

        case .resetAcceptInvitation:
            state.acceptInvitationState = .idle
            state.pendingInvitationInfo = nil
            state.sharingError = nil

        case .clearError:
            state.sharingError = nil

        // MARK: - Join Request Management

        case .setPendingJoinRequests(let requests):
            print("[DEBUG] SharingReducer.setPendingJoinRequests: \(requests.count) requests")
            for req in requests {
                print("[DEBUG]   - userName: '\(req.userName)', participantID: \(req.participantID)")
            }
            state.pendingJoinRequests = requests

        case .startApprovingRequest(let participantID):
            state.processingRequestID = participantID

        case .requestApproved(let participantID):
            state.pendingJoinRequests.removeAll { $0.participantID == participantID }
            state.processingRequestID = nil

        case .startRejectingRequest(let participantID):
            state.processingRequestID = participantID

        case .requestRejected(let participantID):
            state.pendingJoinRequests.removeAll { $0.participantID == participantID }
            state.processingRequestID = nil

        case .requestProcessingFailed(let error):
            state.processingRequestID = nil
            state.sharingError = error

        case .loadPendingJoinRequests:
            // 副作用はAppStoreで処理
            break

        // MARK: - Member List

        case .loadMembers:
            // 副作用はAppStoreで処理
            break

        case .startLoadingMembers:
            state.isLoadingMembers = true

        case .setMembers(let members):
            state.members = members
            state.isLoadingMembers = false

        case .loadMembersFailed(let error):
            state.isLoadingMembers = false
            state.sharingError = error

        // MARK: - Approval Status

        case .setApprovalStatus(let isApproved):
            state.isApprovedMember = isApproved
            state.isCheckingApprovalStatus = false

        case .checkApprovalStatus:
            state.isCheckingApprovalStatus = true
            // 副作用はAppStoreで処理

        // MARK: - Invite Code (Supabase)

        case .startCreatingInviteCode:
            state.isCreatingInviteCode = true

        case .inviteCodeCreated(let code):
            state.generatedInviteCode = code
            state.isCreatingInviteCode = false

        case .inviteCodeCreationFailed(let error):
            state.sharingError = error
            state.isCreatingInviteCode = false

        case .setInviteCodeInput(let input):
            state.inviteCodeInput = input

        case .startJoiningWithCode:
            state.isJoiningWithCode = true

        case .joinedWithCode(let group):
            state.joinedSupabaseGroup = group
            state.isJoiningWithCode = false
            state.inviteCodeInput = ""

        case .joinWithCodeFailed(let error):
            state.sharingError = error
            state.isJoiningWithCode = false

        case .clearGeneratedInviteCode:
            state.generatedInviteCode = nil

        case .resetInviteCodeState:
            state.isCreatingInviteCode = false
            state.generatedInviteCode = nil
            state.inviteCodeInput = ""
            state.isJoiningWithCode = false
            state.joinedSupabaseGroup = nil
            state.sharingError = nil
        }
    }
}
