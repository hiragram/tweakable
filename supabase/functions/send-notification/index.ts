import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// Supabase Database Webhookのペイロード形式
interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: Record<string, unknown>;
  old_record?: Record<string, unknown>;
  schema: string;
}

// 内部で使う通知タイプ
type NotificationType =
  | "assignment_created"
  | "join_request_created"
  | "join_request_approved";

interface FCMMessage {
  token: string;
  notification: {
    title: string;
    body: string;
  };
  data?: Record<string, string>;
}

// FCMトークンを使って通知を送信
async function sendFCMNotification(
  message: FCMMessage,
  serviceAccountKey: string
): Promise<boolean> {
  try {
    const serviceAccount = JSON.parse(serviceAccountKey);
    const accessToken = await getAccessToken(serviceAccount);

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ message }),
      }
    );

    if (!response.ok) {
      const error = await response.text();
      console.error("FCM API error:", error);
      return false;
    }

    console.log("Notification sent successfully");
    return true;
  } catch (error) {
    console.error("Failed to send notification:", error);
    return false;
  }
}

// サービスアカウントからアクセストークンを取得
async function getAccessToken(
  serviceAccount: Record<string, string>
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  };

  // JWTを作成（簡易実装 - 本番ではライブラリ使用推奨）
  const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = btoa(JSON.stringify(payload));
  const signatureInput = `${header}.${claims}`;

  // RS256署名を作成
  const privateKey = serviceAccount.private_key;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(privateKey),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signatureInput)
  );

  const jwt = `${signatureInput}.${btoa(
    String.fromCharCode(...new Uint8Array(signature))
  )
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "")}`;

  // トークンを取得
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenResponse.json();
  return tokenData.access_token;
}

// PEMをDER形式に変換
function pemToDer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

// ユーザーのFCMトークンを取得
async function getFCMToken(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<string | null> {
  const { data, error } = await supabase
    .from("profiles")
    .select("fcm_token")
    .eq("id", userId)
    .single();

  if (error || !data?.fcm_token) {
    return null;
  }
  return data.fcm_token;
}

// ユーザーの表示名を取得
async function getDisplayName(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<string> {
  const { data } = await supabase
    .from("profiles")
    .select("display_name")
    .eq("id", userId)
    .single();

  return data?.display_name || "メンバー";
}

// グループオーナーのユーザーIDを取得
async function getGroupOwnerUserId(
  supabase: ReturnType<typeof createClient>,
  groupId: string
): Promise<string | null> {
  const { data, error } = await supabase
    .from("user_groups")
    .select("owner_id")
    .eq("id", groupId)
    .single();

  if (error || !data) {
    return null;
  }
  return data.owner_id;
}

// 通知メッセージを生成
function createNotificationMessage(
  type: NotificationType,
  record: Record<string, unknown>,
  displayName: string
): { title: string; body: string } {
  switch (type) {
    case "assignment_created": {
      const date = record.date as string;
      const isDropOff = record.assigned_drop_off_user_id !== null;
      const role = isDropOff ? "送り" : "迎え";
      return {
        title: `${date}の${role}担当`,
        body: `${date}の${role}担当に設定されました`,
      };
    }
    case "join_request_created":
      return {
        title: "新しい参加リクエスト",
        body: `${displayName}さんがグループへの参加をリクエストしています`,
      };
    case "join_request_approved":
      return {
        title: "参加が承認されました",
        body: "グループへの参加が承認されました。スケジュールにアクセスできるようになりました",
      };
  }
}

// Webhookペイロードから通知タイプを判定
function determineNotificationType(
  payload: WebhookPayload
): NotificationType | null {
  const { type, table, record, old_record } = payload;

  if (table === "day_assignments") {
    // 担当者割り当ての変更
    if (type === "INSERT") {
      if (record.drop_off_user_id || record.pick_up_user_id) {
        return "assignment_created";
      }
    } else if (type === "UPDATE") {
      // 担当者が変更された場合
      const newDropOff = record.drop_off_user_id;
      const newPickUp = record.pick_up_user_id;
      const oldDropOff = old_record?.drop_off_user_id;
      const oldPickUp = old_record?.pick_up_user_id;

      if (
        (newDropOff && newDropOff !== oldDropOff) ||
        (newPickUp && newPickUp !== oldPickUp)
      ) {
        return "assignment_created";
      }
    }
  } else if (table === "group_memberships") {
    if (type === "INSERT" && record.status === "pending") {
      return "join_request_created";
    } else if (
      type === "UPDATE" &&
      old_record?.status === "pending" &&
      record.status === "approved"
    ) {
      return "join_request_approved";
    }
  }

  return null;
}

Deno.serve(async (req: Request) => {
  try {
    const payload = (await req.json()) as WebhookPayload;
    const { record, old_record, table, type: eventType } = payload;

    console.log("Received webhook:", { table, eventType, record });

    // 通知タイプを判定
    const notificationType = determineNotificationType(payload);
    if (!notificationType) {
      console.log("No notification needed for this event");
      return new Response(
        JSON.stringify({ success: true, message: "No notification needed" }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    console.log("Notification type:", notificationType);

    // 環境変数を取得
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const fcmServiceAccountKey = Deno.env.get("FCM_SERVICE_ACCOUNT_KEY");

    if (!supabaseUrl || !supabaseServiceKey || !fcmServiceAccountKey) {
      throw new Error("Missing environment variables");
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    let targetUserId: string | null = null;
    let senderUserId: string | null = null;

    switch (notificationType) {
      case "assignment_created": {
        // 担当者割り当て: 割り当てられた人に通知
        const newDropOff = record.drop_off_user_id as string | null;
        const newPickUp = record.pick_up_user_id as string | null;
        const oldDropOff = old_record?.drop_off_user_id as string | null;
        const oldPickUp = old_record?.pick_up_user_id as string | null;

        // 新しく割り当てられた人にのみ通知
        if (newDropOff && newDropOff !== oldDropOff) {
          targetUserId = newDropOff;
        } else if (newPickUp && newPickUp !== oldPickUp) {
          targetUserId = newPickUp;
        }
        break;
      }

      case "join_request_created": {
        // 参加リクエスト: グループオーナーに通知
        const groupId = record.group_id as string;
        targetUserId = await getGroupOwnerUserId(supabase, groupId);
        senderUserId = record.user_id as string;
        break;
      }

      case "join_request_approved": {
        // 参加承認: 申請者に通知
        targetUserId = record.user_id as string;
        break;
      }
    }

    if (!targetUserId) {
      console.log("No target user for notification");
      return new Response(
        JSON.stringify({ success: true, message: "No notification needed" }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    // 自分自身への通知は送らない
    if (senderUserId && senderUserId === targetUserId) {
      console.log("Skipping self-notification");
      return new Response(
        JSON.stringify({
          success: true,
          message: "Skipped self-notification",
        }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    // FCMトークンを取得
    const fcmToken = await getFCMToken(supabase, targetUserId);
    if (!fcmToken) {
      console.log("No FCM token for user:", targetUserId);
      return new Response(
        JSON.stringify({ success: true, message: "No FCM token" }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    // 表示名を取得（join_request_createdの場合のみ必要）
    const displayName = senderUserId
      ? await getDisplayName(supabase, senderUserId)
      : "";

    // 通知メッセージを生成
    const { title, body } = createNotificationMessage(
      notificationType,
      record,
      displayName
    );

    // FCM通知を送信
    const success = await sendFCMNotification(
      {
        token: fcmToken,
        notification: { title, body },
        data: {
          type: notificationType,
          record_id: record.id as string,
        },
      },
      fcmServiceAccountKey
    );

    return new Response(JSON.stringify({ success }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error processing notification:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
