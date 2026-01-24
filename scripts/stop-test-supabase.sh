#!/bin/bash
set -e

# テスト用Supabaseインスタンスを停止する共通スクリプト

# デフォルト値
SUPABASE_DIR=""

# ヘルプ表示
show_help() {
    cat << EOF
Usage: $0 -d SUPABASE_DIR

Stop a test Supabase instance and clean up

Options:
    -d SUPABASE_DIR    Path to the supabase directory (required)
    -h                 Show this help message

Example:
    $0 -d supabase
EOF
}

# パラメータ解析
while getopts "d:h" opt; do
    case $opt in
        d)
            SUPABASE_DIR="$OPTARG"
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done

# 必須パラメータチェック
if [ -z "$SUPABASE_DIR" ]; then
    echo "Error: SUPABASE_DIR is required" >&2
    show_help
    exit 1
fi

# ディレクトリが存在するかチェック
if [ ! -d "$SUPABASE_DIR" ]; then
    echo "Warning: Directory $SUPABASE_DIR does not exist, skipping..." >&2
    exit 0
fi

# Supabaseディレクトリに移動
cd "$SUPABASE_DIR"

# プロジェクトIDを取得（環境変数またはconfig.tomlから）
if [ -n "$SUPABASE_PROJECT_ID" ]; then
    PROJECT_ID="$SUPABASE_PROJECT_ID"
    echo "Using project ID from environment: $PROJECT_ID"
elif [ -f "config.toml" ]; then
    # config.tomlからproject_idを抽出
    PROJECT_ID=$(grep -E "^project_id = " config.toml | sed 's/project_id = "\(.*\)"/\1/')
    if [ -n "$PROJECT_ID" ]; then
        echo "Using project ID from config.toml: $PROJECT_ID"
    fi
fi

# Supabaseを停止（データボリュームも含めて完全削除）
echo "Stopping and removing Supabase local instance..."
if [ -n "$PROJECT_ID" ]; then
    # プロジェクトIDが特定できる場合は、そのプロジェクトを確実に削除
    if npx supabase stop --no-backup --project-id "$PROJECT_ID" 2>/dev/null; then
        echo "✓ Supabase stopped and removed successfully (project: $PROJECT_ID)"
    else
        # プロジェクトIDでの削除に失敗した場合、通常の削除を試みる
        echo "Warning: Failed to stop with project ID, trying without..."
        if npx supabase stop --no-backup 2>/dev/null; then
            echo "✓ Supabase stopped and removed successfully"
        else
            echo "Warning: Supabase may not have been running or failed to stop cleanly"
        fi
    fi
else
    # プロジェクトIDが不明な場合は、現在のディレクトリのSupabaseを削除
    if npx supabase stop --no-backup 2>/dev/null; then
        echo "✓ Supabase stopped and removed successfully"
    else
        echo "Warning: Supabase may not have been running or failed to stop cleanly"
    fi
fi

# 動的生成されたconfig.tomlをクリーンアップ
# 注意: 既にcd "$SUPABASE_DIR"しているので、カレントディレクトリで作業
if [ -f "config.toml" ]; then
    echo "Cleaning up generated config.toml..."
    rm -f "config.toml"
    echo "✓ config.toml removed"
fi

# 一時ファイルのクリーンアップ（必要に応じて）
if [ -d ".temp" ]; then
    echo "Cleaning up temporary files..."
    rm -rf ".temp"
fi

echo "Supabase test instance cleanup completed"
