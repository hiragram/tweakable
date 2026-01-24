-- Row Level Security (RLS) policies
-- CloudKitのCKShare + approvedUserIDs をRLSで再現

-- ============================================
-- Enable RLS on all tables
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE invite_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE day_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_locations ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Helper function: 承認済みグループIDを取得
-- ============================================

CREATE OR REPLACE FUNCTION get_approved_group_ids()
RETURNS SETOF UUID AS $$
BEGIN
    RETURN QUERY
    SELECT group_id FROM group_memberships
    WHERE user_id = auth.uid() AND status = 'approved';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- profiles policies
-- ============================================

-- 自分のプロフィールは読み書き可能
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (id = auth.uid());

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (id = auth.uid());

-- 同じグループのメンバーのプロフィールを閲覧可能
CREATE POLICY "Users can view group members profiles"
    ON profiles FOR SELECT
    USING (
        id IN (
            SELECT gm.user_id FROM group_memberships gm
            WHERE gm.group_id IN (SELECT get_approved_group_ids())
            AND gm.status = 'approved'
        )
    );

-- ============================================
-- user_groups policies
-- ============================================

-- 自分が所属する承認済みグループを閲覧可能
CREATE POLICY "Users can view their approved groups"
    ON user_groups FOR SELECT
    USING (id IN (SELECT get_approved_group_ids()));

-- 誰でもグループを作成可能（作成後に自動的にオーナーになる）
CREATE POLICY "Users can create groups"
    ON user_groups FOR INSERT
    WITH CHECK (owner_id = auth.uid());

-- オーナーのみグループを更新可能
CREATE POLICY "Owners can update their groups"
    ON user_groups FOR UPDATE
    USING (owner_id = auth.uid());

-- オーナーのみグループを削除可能
CREATE POLICY "Owners can delete their groups"
    ON user_groups FOR DELETE
    USING (owner_id = auth.uid());

-- ============================================
-- group_memberships policies
-- ============================================

-- 自分のメンバーシップを閲覧可能
CREATE POLICY "Users can view own memberships"
    ON group_memberships FOR SELECT
    USING (user_id = auth.uid());

-- グループオーナーは全メンバーシップを閲覧可能
CREATE POLICY "Owners can view all memberships"
    ON group_memberships FOR SELECT
    USING (
        group_id IN (
            SELECT id FROM user_groups WHERE owner_id = auth.uid()
        )
    );

-- 誰でも自分のメンバーシップを作成可能（pending状態で）
CREATE POLICY "Users can create own membership"
    ON group_memberships FOR INSERT
    WITH CHECK (user_id = auth.uid() AND status = 'pending');

-- オーナーはメンバーシップを更新可能（承認/拒否）
CREATE POLICY "Owners can update memberships"
    ON group_memberships FOR UPDATE
    USING (
        group_id IN (
            SELECT id FROM user_groups WHERE owner_id = auth.uid()
        )
    );

-- オーナーまたは本人がメンバーシップを削除可能
CREATE POLICY "Owners or self can delete membership"
    ON group_memberships FOR DELETE
    USING (
        user_id = auth.uid() OR
        group_id IN (
            SELECT id FROM user_groups WHERE owner_id = auth.uid()
        )
    );

-- ============================================
-- invite_codes policies
-- ============================================

-- 未使用の招待コードは誰でも閲覧可能（コード入力時の検証用）
CREATE POLICY "Anyone can read unused invite codes"
    ON invite_codes FOR SELECT
    USING (used_at IS NULL);

-- グループオーナーのみ招待コードを作成可能
CREATE POLICY "Group owners can create invite codes"
    ON invite_codes FOR INSERT
    WITH CHECK (
        created_by = auth.uid() AND
        EXISTS (
            SELECT 1 FROM user_groups
            WHERE id = group_id AND owner_id = auth.uid()
        )
    );

-- 誰でも招待コードを使用可能（used_by, used_atの更新）
CREATE POLICY "Anyone can use invite codes"
    ON invite_codes FOR UPDATE
    USING (used_at IS NULL)
    WITH CHECK (used_by = auth.uid());

-- ============================================
-- schedule_entries policies
-- ============================================

-- 自分が所属するグループのエントリを閲覧可能
CREATE POLICY "Users can view their group schedules"
    ON schedule_entries FOR SELECT
    USING (group_id IN (SELECT get_approved_group_ids()));

-- 自分のエントリのみ作成可能
CREATE POLICY "Users can create own entries"
    ON schedule_entries FOR INSERT
    WITH CHECK (
        user_id = auth.uid() AND
        group_id IN (SELECT get_approved_group_ids())
    );

-- 自分のエントリのみ更新可能
CREATE POLICY "Users can update own entries"
    ON schedule_entries FOR UPDATE
    USING (user_id = auth.uid());

-- 自分のエントリのみ削除可能
CREATE POLICY "Users can delete own entries"
    ON schedule_entries FOR DELETE
    USING (user_id = auth.uid());

-- ============================================
-- day_assignments policies
-- ============================================

-- 自分が所属するグループの担当割り当てを閲覧可能
CREATE POLICY "Users can view their group assignments"
    ON day_assignments FOR SELECT
    USING (group_id IN (SELECT get_approved_group_ids()));

-- グループメンバーは担当割り当てを作成可能
CREATE POLICY "Members can create assignments"
    ON day_assignments FOR INSERT
    WITH CHECK (group_id IN (SELECT get_approved_group_ids()));

-- グループメンバーは担当割り当てを更新可能
CREATE POLICY "Members can update assignments"
    ON day_assignments FOR UPDATE
    USING (group_id IN (SELECT get_approved_group_ids()));

-- グループメンバーは担当割り当てを削除可能
CREATE POLICY "Members can delete assignments"
    ON day_assignments FOR DELETE
    USING (group_id IN (SELECT get_approved_group_ids()));

-- ============================================
-- weather_locations policies
-- ============================================

-- 自分が所属するグループの天気地点を閲覧可能
CREATE POLICY "Users can view their group weather locations"
    ON weather_locations FOR SELECT
    USING (group_id IN (SELECT get_approved_group_ids()));

-- グループメンバーは天気地点を作成可能
CREATE POLICY "Members can create weather locations"
    ON weather_locations FOR INSERT
    WITH CHECK (group_id IN (SELECT get_approved_group_ids()));

-- グループメンバーは天気地点を更新可能
CREATE POLICY "Members can update weather locations"
    ON weather_locations FOR UPDATE
    USING (group_id IN (SELECT get_approved_group_ids()));

-- グループメンバーは天気地点を削除可能
CREATE POLICY "Members can delete weather locations"
    ON weather_locations FOR DELETE
    USING (group_id IN (SELECT get_approved_group_ids()));
