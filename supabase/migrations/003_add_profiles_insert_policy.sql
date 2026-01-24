-- profiles テーブルに INSERT ポリシーを追加
-- auth.users へのトリガーから呼ばれる handle_new_user 関数が
-- SECURITY DEFINER で実行されるが、RLSポリシーがないと失敗するケースがある

-- サービスロールからの挿入を許可するため、トリガー関数を再定義してRLSをバイパス
-- SECURITY DEFINER + SET search_path を使用
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- また、念のため profiles テーブルに INSERT ポリシーも追加
-- これにより、ユーザー自身が自分のプロフィールを作成できる
CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (id = auth.uid());
