#!/bin/bash
set -e

# 既存の残存Supabaseリソースをクリーンアップするスクリプト
# 安全のため、特定のパターンに一致するものだけを削除

echo "=========================================="
echo "Supabase Old Resources Cleanup Script"
echo "=========================================="

# ドライランモードのフラグ
DRY_RUN=true
if [ "$1" = "--force" ]; then
    DRY_RUN=false
    echo "🔴 Running in FORCE mode - resources will be deleted!"
else
    echo "📋 Running in DRY RUN mode - no actual deletion"
    echo "   To actually delete, run: $0 --force"
fi
echo ""

# 削除対象のプロジェクトパターン
# CI/CDで自動生成されるプロジェクト名のパターンに一致するもののみ
PATTERNS=(
    "okumuka-test-"
    "okumuka-"
)

# 現在のSupabaseコンテナを確認
echo "🔍 Searching for Supabase Docker containers..."
echo ""

# 削除対象のコンテナを収集
CONTAINERS_TO_REMOVE=()
for pattern in "${PATTERNS[@]}"; do
    while IFS= read -r container_id; do
        if [ -n "$container_id" ]; then
            CONTAINERS_TO_REMOVE+=("$container_id")
        fi
    done < <(docker ps -a --filter "name=supabase.*${pattern}" --format "{{.ID}}")
done

# コンテナの削除
if [ ${#CONTAINERS_TO_REMOVE[@]} -gt 0 ]; then
    echo "📦 Found ${#CONTAINERS_TO_REMOVE[@]} containers to remove:"
    for container in "${CONTAINERS_TO_REMOVE[@]}"; do
        container_info=$(docker ps -a --filter "id=$container" --format "{{.Names}} ({{.Status}}, {{.CreatedAt}})")
        echo "   - $container_info"
    done
    echo ""

    if [ "$DRY_RUN" = false ]; then
        echo "Removing containers..."
        for container in "${CONTAINERS_TO_REMOVE[@]}"; do
            echo -n "   Removing $container... "
            if docker rm -f "$container" 2>/dev/null; then
                echo "✓"
            else
                echo "⚠️ Failed"
            fi
        done
    fi
else
    echo "✅ No old containers found"
fi
echo ""

# 現在のSupabaseボリュームを確認
echo "🔍 Searching for Supabase Docker volumes..."
echo ""

# 削除対象のボリュームを収集
VOLUMES_TO_REMOVE=()
for pattern in "${PATTERNS[@]}"; do
    while IFS= read -r volume_name; do
        if [ -n "$volume_name" ]; then
            VOLUMES_TO_REMOVE+=("$volume_name")
        fi
    done < <(docker volume ls --filter "name=supabase.*${pattern}" --format "{{.Name}}")
done

# ボリュームの削除
if [ ${#VOLUMES_TO_REMOVE[@]} -gt 0 ]; then
    echo "💾 Found ${#VOLUMES_TO_REMOVE[@]} volumes to remove:"

    # 最初の10個だけ表示（多すぎる場合のため）
    count=0
    for volume in "${VOLUMES_TO_REMOVE[@]}"; do
        if [ $count -lt 10 ]; then
            echo "   - $volume"
            count=$((count + 1))
        else
            echo "   ... and $((${#VOLUMES_TO_REMOVE[@]} - 10)) more"
            break
        fi
    done
    echo ""

    if [ "$DRY_RUN" = false ]; then
        echo "Removing volumes..."
        removed_count=0
        failed_count=0
        for volume in "${VOLUMES_TO_REMOVE[@]}"; do
            if docker volume rm "$volume" 2>/dev/null; then
                removed_count=$((removed_count + 1))
            else
                failed_count=$((failed_count + 1))
            fi
            # 進捗表示
            if [ $((removed_count % 50)) -eq 0 ] && [ $removed_count -gt 0 ]; then
                echo "   Progress: $removed_count removed..."
            fi
        done
        echo "   ✓ Removed: $removed_count volumes"
        if [ $failed_count -gt 0 ]; then
            echo "   ⚠️ Failed: $failed_count volumes (may be in use)"
        fi
    fi
else
    echo "✅ No old volumes found"
fi
echo ""

# ディスク使用量の確認
echo "📊 Docker disk usage:"
docker system df | grep -E "^(TYPE|Images|Containers|Local Volumes)"
echo ""

# プルーニングの提案
if [ "$DRY_RUN" = true ]; then
    echo "💡 Additional cleanup suggestions:"
    echo "   1. Run this script with --force to remove the listed resources"
    echo "   2. After cleanup, you can also run:"
    echo "      docker system prune --volumes -f"
    echo "      (This will remove ALL unused volumes, not just Supabase ones)"
else
    echo "✅ Cleanup completed!"
    echo ""
    echo "💡 For additional cleanup, you can run:"
    echo "   docker system prune --volumes -f"
    echo "   (This will remove ALL unused volumes across all projects)"
fi
