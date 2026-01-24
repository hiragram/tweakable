#!/bin/bash
set -e

# テスト用Supabaseインスタンスをセットアップする共通スクリプト
# 動的ポート割り当てとconfig.tomlの更新を行います

# デフォルト値
SUPABASE_DIR=""
PROJECT_PREFIX="okumuka-test"
WAIT_TIME=15

# ヘルプ表示
show_help() {
    cat << EOF
Usage: $0 -d SUPABASE_DIR [-p PROJECT_PREFIX] [-w WAIT_TIME]

Setup a test Supabase instance with dynamic ports

Options:
    -d SUPABASE_DIR    Path to the supabase directory (required)
    -p PROJECT_PREFIX  Prefix for the project ID (default: okumuka-test)
    -w WAIT_TIME       Wait time after starting Supabase in seconds (default: 15)
    -h                 Show this help message

Example:
    $0 -d supabase -p okumuka-test
EOF
}

# パラメータ解析
while getopts "d:p:w:h" opt; do
    case $opt in
        d)
            SUPABASE_DIR="$OPTARG"
            ;;
        p)
            PROJECT_PREFIX="$OPTARG"
            ;;
        w)
            WAIT_TIME="$OPTARG"
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
    echo "Error: Directory $SUPABASE_DIR does not exist" >&2
    exit 1
fi

# 動的ポート生成
echo "Generating unique ports for Supabase instance..."
BASE_PORT=$((50000 + RANDOM % 10000))
SUPABASE_API_PORT=$((BASE_PORT + 1))
DB_PORT=$((BASE_PORT + 2))
SHADOW_PORT=$((BASE_PORT + 3))
STUDIO_PORT=$((BASE_PORT + 4))
INBUCKET_PORT=$((BASE_PORT + 5))
ANALYTICS_PORT=$((BASE_PORT + 6))
EDGE_RUNTIME_PORT=$((BASE_PORT + 7))

# プロジェクトIDの生成（短縮版を使用）
if [ -n "$GITHUB_RUN_ID" ]; then
    SHORT_ID=$(echo "$GITHUB_RUN_ID" | tail -c 9)
else
    SHORT_ID=$(date +%s | tail -c 9)
fi
SUPABASE_PROJECT_ID="${PROJECT_PREFIX}-${SHORT_ID}"

# 環境変数をエクスポート
export SUPABASE_API_PORT
export DB_PORT
export SHADOW_PORT
export STUDIO_PORT
export INBUCKET_PORT
export MAILPIT_PORT=$INBUCKET_PORT
export ANALYTICS_PORT
export EDGE_RUNTIME_PORT
export SUPABASE_PROJECT_ID
export DATABASE_PORT=$DB_PORT

echo "Generated ports:"
echo "  SUPABASE_API_PORT: $SUPABASE_API_PORT"
echo "  DB_PORT: $DB_PORT"
echo "  SHADOW_PORT: $SHADOW_PORT"
echo "  STUDIO_PORT: $STUDIO_PORT"
echo "  INBUCKET_PORT: $INBUCKET_PORT"
echo "  MAILPIT_PORT: $MAILPIT_PORT"
echo "  ANALYTICS_PORT: $ANALYTICS_PORT"
echo "  EDGE_RUNTIME_PORT: $EDGE_RUNTIME_PORT"
echo "  PROJECT_ID: $SUPABASE_PROJECT_ID"

# config.tomlの生成
CONFIG_DEFAULT="$SUPABASE_DIR/config.toml.default"
CONFIG_FILE="$SUPABASE_DIR/config.toml"

if [ ! -f "$CONFIG_DEFAULT" ]; then
    echo "Error: config.toml.default not found at $CONFIG_DEFAULT" >&2
    exit 1
fi

# クリーンアップ: 前回の実行で残ったconfig.tomlがあれば削除
if [ -f "$CONFIG_FILE" ]; then
    echo "Cleaning up existing config.toml from previous run..."
    rm -f "$CONFIG_FILE"
fi

echo "Creating config.toml from config.toml.default..."
cp "$CONFIG_DEFAULT" "$CONFIG_FILE"

echo "Updating config.toml with dynamic ports..."

# OSを判定してsedコマンドを調整
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    SED_INPLACE_CMD() {
        sed -i '' "$@"
    }
else
    # Linux
    SED_INPLACE_CMD() {
        sed -i "$@"
    }
fi

# config.tomlを更新
cd "$SUPABASE_DIR"
SED_INPLACE_CMD "s/^port = [0-9]*/port = $SUPABASE_API_PORT/" config.toml
SED_INPLACE_CMD "/^\[db\]/,/^\[/ s/^port = [0-9]*/port = $DB_PORT/" config.toml
SED_INPLACE_CMD "s/^shadow_port = [0-9]*/shadow_port = $SHADOW_PORT/" config.toml
SED_INPLACE_CMD "/^\[studio\]/,/^\[/ s/^port = [0-9]*/port = $STUDIO_PORT/" config.toml
SED_INPLACE_CMD "/^\[inbucket\]/,/^\[/ s/^port = [0-9]*/port = $INBUCKET_PORT/" config.toml
SED_INPLACE_CMD "/^\[analytics\]/,/^\[/ s/^port = [0-9]*/port = $ANALYTICS_PORT/" config.toml
SED_INPLACE_CMD "s/^inspector_port = [0-9]*/inspector_port = $EDGE_RUNTIME_PORT/" config.toml
SED_INPLACE_CMD "s/^project_id = .*/project_id = \"$SUPABASE_PROJECT_ID\"/" config.toml

# 更新されたポートを確認
echo "=== Updated config.toml ports ==="
grep -E "(port|project_id)" config.toml | head -20
echo "================================="

# Supabaseを起動
echo "Starting Supabase local instance..."
npx supabase start

echo "Waiting $WAIT_TIME seconds for Supabase to be ready..."
sleep $WAIT_TIME

# Supabaseの認証エンドポイントが応答するまで待つ
echo "Checking Supabase auth endpoint availability..."
MAX_RETRIES=30
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$SUPABASE_API_PORT/auth/v1/health" 2>/dev/null | grep -q "200"; then
        echo "✓ Supabase auth endpoint is ready"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Waiting for Supabase auth endpoint... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Warning: Supabase auth endpoint may not be fully ready after $MAX_RETRIES attempts"
fi

# Supabase認証情報を設定
echo "Setting Supabase local credentials..."

# 環境変数が設定されていればそれを使用、なければデフォルト値を使用
if [ -z "$SUPABASE_ANON_KEY" ]; then
    ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
    echo "Using default SUPABASE_ANON_KEY"
else
    ANON_KEY="$SUPABASE_ANON_KEY"
    echo "Using provided SUPABASE_ANON_KEY"
fi

if [ -z "$SUPABASE_SERVICE_KEY" ]; then
    SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU"
    echo "Using default SUPABASE_SERVICE_KEY"
else
    SERVICE_KEY="$SUPABASE_SERVICE_KEY"
    echo "Using provided SUPABASE_SERVICE_KEY"
fi

# 環境変数を設定（GitHub Actionsの場合）
if [ -n "$GITHUB_ENV" ]; then
    {
        echo "SUPABASE_URL=http://localhost:$SUPABASE_API_PORT"
        echo "SUPABASE_ANON_KEY=$ANON_KEY"
        echo "SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY"
        echo "DATABASE_HOST=localhost"
        echo "DATABASE_PORT=$DB_PORT"
        echo "DATABASE_NAME=postgres"
        echo "DATABASE_USER=postgres"
        echo "DATABASE_PASSWORD=postgres"
        echo "SUPABASE_API_PORT=$SUPABASE_API_PORT"
        echo "DB_PORT=$DB_PORT"
        echo "SHADOW_PORT=$SHADOW_PORT"
        echo "STUDIO_PORT=$STUDIO_PORT"
        echo "INBUCKET_PORT=$INBUCKET_PORT"
        echo "MAILPIT_PORT=$INBUCKET_PORT"
        echo "ANALYTICS_PORT=$ANALYTICS_PORT"
        echo "EDGE_RUNTIME_PORT=$EDGE_RUNTIME_PORT"
        echo "SUPABASE_PROJECT_ID=$SUPABASE_PROJECT_ID"
    } >> "$GITHUB_ENV"
    echo "Environment variables have been exported to GITHUB_ENV"
else
    # 通常のシェル環境用にエクスポート
    export SUPABASE_URL="http://localhost:$SUPABASE_API_PORT"
    export SUPABASE_ANON_KEY="$ANON_KEY"
    export SUPABASE_SERVICE_ROLE_KEY="$SERVICE_KEY"
    export DATABASE_HOST="localhost"
    export DATABASE_NAME="postgres"
    export DATABASE_USER="postgres"
    export DATABASE_PASSWORD="postgres"
    export MAILPIT_PORT=$INBUCKET_PORT
    echo "Environment variables have been exported to current shell"
fi

echo "Supabase test instance setup completed successfully!"
echo "  SUPABASE_URL: http://localhost:$SUPABASE_API_PORT"
echo "  DATABASE_PORT: $DB_PORT"
