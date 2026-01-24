import Foundation
import Supabase

/// Supabaseストレージサービスエラー
public enum SupabaseStorageError: Error, Sendable {
    case notFound
    case networkError
    case invalidData
    case unauthorized
    case unknown(String)
}

/// 実際のSupabaseストレージサービス
/// supabase-swiftを使ってデータベース操作を行う
public final class SupabaseStorageService: SupabaseStorageServiceProtocol, @unchecked Sendable {
    private let client: Supabase.SupabaseClient

    public init(supabaseURL: URL, supabaseKey: String) {
        self.client = Supabase.SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }

    // MARK: - Profile Operations

    public func saveProfile(_ profile: Profile) async throws -> Profile {
        do {
            let result: Profile = try await client
                .from("profiles")
                .upsert(profile)
                .select()
                .single()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func fetchProfile(userID: UUID) async throws -> Profile? {
        do {
            let result: Profile? = try await client
                .from("profiles")
                .select()
                .eq("id", value: userID.uuidString)
                .single()
                .execute()
                .value
            return result
        } catch {
            // レコードが見つからない場合はnilを返す
            return nil
        }
    }

    public func saveFCMToken(_ token: String, userID: UUID) async throws {
        do {
            try await client
                .from("profiles")
                .update(["fcm_token": token])
                .eq("id", value: userID.uuidString)
                .execute()
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Group Operations

    public func createGroup(_ group: SupabaseUserGroup) async throws -> SupabaseUserGroup {
        do {
            let result: SupabaseUserGroup = try await client
                .from("user_groups")
                .insert(group)
                .select()
                .single()
                .execute()
                .value

            // オーナーのメンバーシップを自動作成（approved状態で）
            let membership = SupabaseGroupMembership(
                id: UUID(),
                userID: group.ownerID,
                groupID: group.id,
                status: .approved
            )
            _ = try await client
                .from("group_memberships")
                .insert(membership)
                .execute()

            return result
        } catch {
            throw mapError(error)
        }
    }

    public func fetchGroup(groupID: UUID) async throws -> SupabaseUserGroup? {
        do {
            let result: SupabaseUserGroup? = try await client
                .from("user_groups")
                .select()
                .eq("id", value: groupID.uuidString)
                .single()
                .execute()
                .value
            return result
        } catch {
            return nil
        }
    }

    public func fetchGroupsForUser(userID: UUID) async throws -> [SupabaseUserGroup] {
        do {
            // 承認済みメンバーシップのグループIDを取得
            let memberships: [SupabaseGroupMembership] = try await client
                .from("group_memberships")
                .select()
                .eq("user_id", value: userID.uuidString)
                .eq("status", value: "approved")
                .execute()
                .value

            let groupIDs = memberships.map { $0.groupID.uuidString }

            if groupIDs.isEmpty {
                return []
            }

            let groups: [SupabaseUserGroup] = try await client
                .from("user_groups")
                .select()
                .in("id", values: groupIDs)
                .execute()
                .value

            return groups
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Membership Operations

    public func createMembership(userID: UUID, groupID: UUID) async throws -> SupabaseGroupMembership {
        do {
            let membership = SupabaseGroupMembership(
                id: UUID(),
                userID: userID,
                groupID: groupID,
                status: .pending
            )
            let result: SupabaseGroupMembership = try await client
                .from("group_memberships")
                .insert(membership)
                .select()
                .single()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func updateMembershipStatus(membershipID: UUID, status: SupabaseMembershipStatus) async throws {
        do {
            try await client
                .from("group_memberships")
                .update(["status": status.rawValue])
                .eq("id", value: membershipID.uuidString)
                .execute()
        } catch {
            throw mapError(error)
        }
    }

    public func fetchPendingMemberships(groupID: UUID) async throws -> [SupabaseGroupMembership] {
        do {
            let result: [SupabaseGroupMembership] = try await client
                .from("group_memberships")
                .select()
                .eq("group_id", value: groupID.uuidString)
                .eq("status", value: "pending")
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func fetchGroupMemberships(groupID: UUID) async throws -> [SupabaseGroupMembership] {
        do {
            let result: [SupabaseGroupMembership] = try await client
                .from("group_memberships")
                .select()
                .eq("group_id", value: groupID.uuidString)
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Schedule Entry Operations

    public func saveScheduleEntry(_ entry: SupabaseScheduleEntry) async throws -> SupabaseScheduleEntry {
        do {
            let result: SupabaseScheduleEntry = try await client
                .from("schedule_entries")
                .upsert(entry)
                .select()
                .single()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func saveScheduleEntries(_ entries: [SupabaseScheduleEntry]) async throws -> [SupabaseScheduleEntry] {
        do {
            let result: [SupabaseScheduleEntry] = try await client
                .from("schedule_entries")
                .upsert(entries)
                .select()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func fetchScheduleEntries(groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseScheduleEntry] {
        do {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]

            let result: [SupabaseScheduleEntry] = try await client
                .from("schedule_entries")
                .select()
                .eq("group_id", value: groupID.uuidString)
                .gte("date", value: formatter.string(from: startDate))
                .lte("date", value: formatter.string(from: endDate))
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func fetchScheduleEntries(userID: UUID, groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseScheduleEntry] {
        do {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]

            let result: [SupabaseScheduleEntry] = try await client
                .from("schedule_entries")
                .select()
                .eq("user_id", value: userID.uuidString)
                .eq("group_id", value: groupID.uuidString)
                .gte("date", value: formatter.string(from: startDate))
                .lte("date", value: formatter.string(from: endDate))
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Day Assignment Operations

    public func saveDayAssignment(_ assignment: SupabaseDayAssignment) async throws -> SupabaseDayAssignment {
        do {
            let result: SupabaseDayAssignment = try await client
                .from("day_assignments")
                .upsert(assignment)
                .select()
                .single()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func saveDayAssignments(_ assignments: [SupabaseDayAssignment]) async throws -> [SupabaseDayAssignment] {
        do {
            let result: [SupabaseDayAssignment] = try await client
                .from("day_assignments")
                .upsert(assignments)
                .select()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func fetchDayAssignments(groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseDayAssignment] {
        do {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]

            let result: [SupabaseDayAssignment] = try await client
                .from("day_assignments")
                .select()
                .eq("group_id", value: groupID.uuidString)
                .gte("date", value: formatter.string(from: startDate))
                .lte("date", value: formatter.string(from: endDate))
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Weather Location Operations

    public func saveWeatherLocation(_ location: SupabaseWeatherLocation) async throws -> SupabaseWeatherLocation {
        do {
            let result: SupabaseWeatherLocation = try await client
                .from("weather_locations")
                .upsert(location)
                .select()
                .single()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func fetchWeatherLocations(groupID: UUID) async throws -> [SupabaseWeatherLocation] {
        do {
            let result: [SupabaseWeatherLocation] = try await client
                .from("weather_locations")
                .select()
                .eq("group_id", value: groupID.uuidString)
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func deleteWeatherLocation(_ location: SupabaseWeatherLocation) async throws {
        do {
            try await client
                .from("weather_locations")
                .delete()
                .eq("id", value: location.id.uuidString)
                .execute()
        } catch {
            throw mapError(error)
        }
    }

    public func deleteWeatherLocation(locationID: UUID) async throws {
        do {
            try await client
                .from("weather_locations")
                .delete()
                .eq("id", value: locationID.uuidString)
                .execute()
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Invite Code Operations

    public func createInviteCode(groupID: UUID, createdBy: UUID) async throws -> SupabaseInviteCode {
        do {
            // 6桁英数大文字コードを生成
            let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let code = String((0..<6).map { _ in characters.randomElement()! })

            let inviteCode = SupabaseInviteCode(
                id: UUID(),
                code: code,
                groupID: groupID,
                createdBy: createdBy
            )
            let result: SupabaseInviteCode = try await client
                .from("invite_codes")
                .insert(inviteCode)
                .select()
                .single()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func fetchInviteCode(code: String) async throws -> SupabaseInviteCode? {
        do {
            let result: SupabaseInviteCode? = try await client
                .from("invite_codes")
                .select()
                .eq("code", value: code)
                .is("used_at", value: nil)
                .single()
                .execute()
                .value
            return result
        } catch {
            // レコードが見つからない場合はnilを返す
            return nil
        }
    }

    public func useInviteCode(code: String, usedBy: UUID) async throws -> SupabaseInviteCode {
        do {
            let result: SupabaseInviteCode = try await client
                .from("invite_codes")
                .update([
                    "used_by": usedBy.uuidString,
                    "used_at": ISO8601DateFormatter().string(from: Date())
                ])
                .eq("code", value: code)
                .is("used_at", value: nil)
                .select()
                .single()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    public func addMemberApproved(userID: UUID, groupID: UUID) async throws -> SupabaseGroupMembership {
        do {
            let membership = SupabaseGroupMembership(
                id: UUID(),
                userID: userID,
                groupID: groupID,
                status: .approved
            )
            let result: SupabaseGroupMembership = try await client
                .from("group_memberships")
                .insert(membership)
                .select()
                .single()
                .execute()
                .value
            return result
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Private

    private func mapError(_ error: Error) -> SupabaseStorageError {
        let errorDescription = error.localizedDescription.lowercased()

        if errorDescription.contains("network") || errorDescription.contains("connection") {
            return .networkError
        }

        if errorDescription.contains("not found") || errorDescription.contains("no rows") {
            return .notFound
        }

        if errorDescription.contains("unauthorized") || errorDescription.contains("401") {
            return .unauthorized
        }

        return .unknown(error.localizedDescription)
    }
}
