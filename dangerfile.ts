import { danger, markdown, warn } from "danger";
import * as fs from "fs";

// .claude/settings.jsonの変更をチェック
const claudeSettingsFile = ".claude/settings.json";
const modifiedFiles = danger.git.modified_files;
const createdFiles = danger.git.created_files;

if (modifiedFiles.includes(claudeSettingsFile) || createdFiles.includes(claudeSettingsFile)) {
  const diff = danger.git.diffForFile(claudeSettingsFile);
  diff.then(function(fileDiff) {
    if (fileDiff) {
      let summary = "Claude Code設定ファイル (`.claude/settings.json`) が変更されました。\n\n";
      summary += "**変更内容:**\n";
      summary += "```diff\n";
      summary += fileDiff.diff;
      summary += "\n```\n";
      warn(summary);
    }
  });
}

// cmlでアップロードされたスナップショット画像のURLを読み込む
const snapshotUrlsFile = "snapshot-urls.json";

if (fs.existsSync(snapshotUrlsFile)) {
  const data = JSON.parse(fs.readFileSync(snapshotUrlsFile, "utf8"));
  const snapshots = data.snapshots;

  if (snapshots && snapshots.length > 0) {
    // タイプ別にグループ化
    const added = snapshots.filter(function(s) { return s.type === "added"; });
    const deleted = snapshots.filter(function(s) { return s.type === "deleted"; });
    const modified = snapshots.filter(function(s) { return s.type === "modified"; });

    let content = `## スナップショット変更\n\n`;

    // 追加されたスナップショット
    if (added.length > 0) {
      content += `### 追加 (${added.length}件)\n\n`;
      for (const snapshot of added) {
        content += `**${snapshot.name}**\n\n`;
        content += `| 新規 |\n`;
        content += `|:----:|\n`;
        content += `| <img src="${snapshot.after}" width="300" /> |\n\n`;
      }
    }

    // 削除されたスナップショット
    if (deleted.length > 0) {
      content += `### 削除 (${deleted.length}件)\n\n`;
      for (const snapshot of deleted) {
        content += `**${snapshot.name}**\n\n`;
        content += `| 削除 |\n`;
        content += `|:----:|\n`;
        content += `| <img src="${snapshot.before}" width="300" /> |\n\n`;
      }
    }

    // 変更されたスナップショット
    if (modified.length > 0) {
      content += `### 変更 (${modified.length}件)\n\n`;
      for (const snapshot of modified) {
        content += `**${snapshot.name}**\n\n`;
        content += `| Before | After | Diff |\n`;
        content += `|:------:|:-----:|:----:|\n`;
        content += `| <img src="${snapshot.before}" width="250" /> | <img src="${snapshot.after}" width="250" /> | <img src="${snapshot.diff}" width="250" /> |\n\n`;
      }
    }

    markdown(content);
  }
}
