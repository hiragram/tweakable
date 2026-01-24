-- Initial schema for Okumuka app
-- CloudKit models → PostgreSQL migration

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ENUM types
-- ============================================

-- メンバーシップステータス
CREATE TYPE membership_status AS ENUM ('pending', 'approved', 'rejected');

-- スケジュールステータス
CREATE TYPE schedule_status AS ENUM ('not_set', 'ok', 'ng');

-- ============================================
-- Tables
-- ============================================

-- profiles: ユーザープロフィール（auth.usersと1:1）
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    fcm_token TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- user_groups: ユーザーグループ（家族など）
CREATE TABLE user_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    -- 有効な曜日（JSON: {"sunday": false, "monday": true, ...}）
    enabled_weekdays JSONB NOT NULL DEFAULT '{
        "sunday": false,
        "monday": true,
        "tuesday": true,
        "wednesday": true,
        "thursday": true,
        "friday": true,
        "saturday": false
    }'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- group_memberships: グループへの所属関係
CREATE TABLE group_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES user_groups(id) ON DELETE CASCADE,
    status membership_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, group_id)
);

-- invite_codes: 招待コード
CREATE TABLE invite_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code CHAR(6) NOT NULL UNIQUE,
    group_id UUID NOT NULL REFERENCES user_groups(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    used_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- schedule_entries: 1日分のスケジュールエントリ
CREATE TABLE schedule_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES user_groups(id) ON DELETE CASCADE,
    drop_off_status schedule_status NOT NULL DEFAULT 'not_set',
    pick_up_status schedule_status NOT NULL DEFAULT 'not_set',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(date, user_id, group_id)
);

-- day_assignments: 1日分の担当者割り当て
CREATE TABLE day_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL,
    group_id UUID NOT NULL REFERENCES user_groups(id) ON DELETE CASCADE,
    assigned_drop_off_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    assigned_pick_up_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(date, group_id)
);

-- weather_locations: 天気予報を取得する地点
CREATE TABLE weather_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    label TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    place_name TEXT NOT NULL,
    group_id UUID NOT NULL REFERENCES user_groups(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- Indexes
-- ============================================

-- グループメンバーシップの検索最適化
CREATE INDEX idx_group_memberships_user_id ON group_memberships(user_id);
CREATE INDEX idx_group_memberships_group_id ON group_memberships(group_id);
CREATE INDEX idx_group_memberships_status ON group_memberships(status);

-- 招待コードの検索最適化
CREATE INDEX idx_invite_codes_code ON invite_codes(code) WHERE used_at IS NULL;
CREATE INDEX idx_invite_codes_group_id ON invite_codes(group_id);

-- スケジュールエントリの検索最適化
CREATE INDEX idx_schedule_entries_date ON schedule_entries(date);
CREATE INDEX idx_schedule_entries_user_id ON schedule_entries(user_id);
CREATE INDEX idx_schedule_entries_group_id ON schedule_entries(group_id);
CREATE INDEX idx_schedule_entries_date_group ON schedule_entries(date, group_id);

-- 担当者割り当ての検索最適化
CREATE INDEX idx_day_assignments_date ON day_assignments(date);
CREATE INDEX idx_day_assignments_group_id ON day_assignments(group_id);
CREATE INDEX idx_day_assignments_date_group ON day_assignments(date, group_id);

-- 天気地点の検索最適化
CREATE INDEX idx_weather_locations_group_id ON weather_locations(group_id);

-- ============================================
-- Functions
-- ============================================

-- updated_atを自動更新するトリガー関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Triggers
-- ============================================

-- profiles の updated_at 自動更新
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- user_groups の updated_at 自動更新
CREATE TRIGGER update_user_groups_updated_at
    BEFORE UPDATE ON user_groups
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- group_memberships の updated_at 自動更新
CREATE TRIGGER update_group_memberships_updated_at
    BEFORE UPDATE ON group_memberships
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- schedule_entries の updated_at 自動更新
CREATE TRIGGER update_schedule_entries_updated_at
    BEFORE UPDATE ON schedule_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- day_assignments の updated_at 自動更新
CREATE TRIGGER update_day_assignments_updated_at
    BEFORE UPDATE ON day_assignments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- weather_locations の updated_at 自動更新
CREATE TRIGGER update_weather_locations_updated_at
    BEFORE UPDATE ON weather_locations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Auth trigger: プロフィール自動作成
-- ============================================

-- 新規ユーザー登録時にprofilesレコードを自動作成
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, display_name)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();
