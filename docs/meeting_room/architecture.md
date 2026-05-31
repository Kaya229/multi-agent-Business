# 会議室予約システム MVP - アーキテクチャ設計書

**Project ID**: meeting_room
**Version**: 1.0.0
**Created**: 2026-02-02
**Tech Lead**: Tech Lead Agent

---

## 1. システムアーキテクチャ

### 1.1 技術スタック

| レイヤー | 技術 | 用途 |
|---------|------|------|
| Frontend | Next.js 14 (App Router) | SSR/CSR対応のフロントエンド |
| Styling | Tailwind CSS | ユーティリティファーストCSS |
| Backend | Supabase | 認証・DB・Realtime・Edge Functions |
| Auth | Supabase Auth + Google OAuth | Googleアカウント認証 |
| Database | PostgreSQL (Supabase) | リレーショナルDB |
| Deploy | Vercel | Frontendデプロイ |

### 1.2 システム構成図

```
┌─────────────────────────────────────────────────────────┐
│                       User (Browser)                    │
└─────────────┬───────────────────────────────────────────┘
              │ HTTPS
              ▼
┌─────────────────────────────────────────────────────────┐
│               Vercel (Frontend Hosting)                 │
│  ┌───────────────────────────────────────────────────┐  │
│  │           Next.js App (App Router)                │  │
│  │  ┌──────────────┐  ┌──────────────────────────┐  │  │
│  │  │  Pages       │  │  Components              │  │  │
│  │  │  - Login     │  │  - Calendar              │  │  │
│  │  │  - Dashboard │  │  - ReservationModal      │  │  │
│  │  │  - Booking   │  │  - RoomCard              │  │  │
│  │  └──────────────┘  └──────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────┬───────────────────────────────────────────┘
              │ HTTPS (Supabase Client)
              ▼
┌─────────────────────────────────────────────────────────┐
│                  Supabase Backend                       │
│  ┌──────────────────┐  ┌──────────────────────────┐    │
│  │  Auth            │  │  PostgreSQL Database     │    │
│  │  - Google OAuth  │  │  - users                 │    │
│  │                  │  │  - meeting_rooms         │    │
│  │                  │  │  - reservations          │    │
│  └──────────────────┘  └──────────────────────────┘    │
│  ┌──────────────────┐  ┌──────────────────────────┐    │
│  │  Realtime        │  │  Row Level Security      │    │
│  │  - 予約更新通知  │  │  - ユーザー別権限制御    │    │
│  └──────────────────┘  └──────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

---

## 2. ディレクトリ構成

```
meeting_room_mvp/
├── src/
│   ├── app/                      # Next.js App Router
│   │   ├── layout.tsx            # ルートレイアウト
│   │   ├── page.tsx              # ランディングページ（ログイン）
│   │   ├── dashboard/
│   │   │   └── page.tsx          # 予約ダッシュボード
│   │   ├── booking/
│   │   │   └── page.tsx          # 予約作成・編集ページ
│   │   └── api/                  # API Routes（必要に応じて）
│   ├── components/               # 共通コンポーネント
│   │   ├── auth/
│   │   │   └── LoginButton.tsx   # Googleログインボタン
│   │   ├── calendar/
│   │   │   ├── CalendarView.tsx  # カレンダー表示
│   │   │   └── TimeSlot.tsx      # 時間枠コンポーネント
│   │   ├── room/
│   │   │   ├── RoomCard.tsx      # 会議室カード
│   │   │   └── RoomSelector.tsx  # 会議室選択
│   │   └── reservation/
│   │       ├── ReservationModal.tsx # 予約モーダル
│   │       └── ReservationList.tsx  # 予約一覧
│   ├── lib/                      # ユーティリティ・ロジック
│   │   ├── supabase/
│   │   │   ├── client.ts         # Supabaseクライアント初期化
│   │   │   ├── auth.ts           # 認証ヘルパー
│   │   │   └── queries.ts        # DB操作関数
│   │   ├── utils/
│   │   │   ├── dateUtils.ts      # 日付操作
│   │   │   └── validation.ts     # バリデーション
│   │   └── types/
│   │       └── index.ts          # 型定義
│   └── styles/                   # グローバルスタイル
│       └── globals.css           # Tailwind + カスタムCSS
├── supabase/
│   ├── migrations/               # DBマイグレーション
│   │   └── 20260202_initial.sql  # 初期スキーマ
│   └── config.toml               # Supabase設定
├── public/                       # 静的ファイル
├── .env.local                    # 環境変数（Supabaseキー等）
├── next.config.js                # Next.js設定
├── tailwind.config.ts            # Tailwind設定
├── tsconfig.json                 # TypeScript設定
└── package.json                  # 依存関係
```

---

## 3. データベース設計

### 3.1 ER図（テキスト表現）

```
users (Supabase Auth)
  ↓ (1:N)
reservations
  ↓ (N:1)
meeting_rooms
```

### 3.2 テーブル定義

#### 3.2.1 users（Supabase Authデフォルトテーブル）

| カラム名 | 型 | 制約 | 説明 |
|---------|------|------|------|
| id | uuid | PK | Supabase Auth User ID |
| email | text | UNIQUE | Googleアカウントメール |
| created_at | timestamptz | NOT NULL | 作成日時 |

**備考**: Supabase Authが管理するため、明示的なマイグレーションは不要。

---

#### 3.2.2 meeting_rooms

| カラム名 | 型 | 制約 | 説明 |
|---------|------|------|------|
| id | text | PK | 会議室ID（例: room_a） |
| name | text | NOT NULL | 表示名（例: "会議室A"） |
| capacity | int | NOT NULL | 定員 |
| color | text | NOT NULL | カレンダー表示色 |
| created_at | timestamptz | NOT NULL DEFAULT now() | 作成日時 |

**初期データ**:
```sql
INSERT INTO meeting_rooms (id, name, capacity, color) VALUES
  ('room_a', '会議室A', 10, '#3B82F6'),
  ('room_b', '会議室B', 6, '#06B6D4'),
  ('room_c', '会議室C', 4, '#0EA5E9');
```

---

#### 3.2.3 reservations

| カラム名 | 型 | 制約 | 説明 |
|---------|------|------|------|
| id | uuid | PK DEFAULT gen_random_uuid() | 予約ID |
| room_id | text | FK → meeting_rooms.id | 会議室ID |
| user_id | uuid | FK → auth.users.id | 予約者ID |
| start_time | timestamptz | NOT NULL | 開始時刻 |
| end_time | timestamptz | NOT NULL | 終了時刻 |
| title | text | NOT NULL | 予約タイトル |
| description | text | NULL | 備考 |
| created_at | timestamptz | NOT NULL DEFAULT now() | 予約作成日時 |
| updated_at | timestamptz | NOT NULL DEFAULT now() | 最終更新日時 |

**制約**:
- `CHECK (end_time > start_time)` - 終了時刻は開始時刻より後
- `UNIQUE (room_id, start_time, end_time)` - 同じ会議室・時間帯の重複予約禁止

**インデックス**:
```sql
CREATE INDEX idx_reservations_room_time ON reservations(room_id, start_time, end_time);
CREATE INDEX idx_reservations_user ON reservations(user_id);
```

---

### 3.3 Row Level Security (RLS) ポリシー

#### meeting_rooms
```sql
-- 全員が読み取り可能
CREATE POLICY "meeting_rooms_select" ON meeting_rooms FOR SELECT USING (true);
```

#### reservations
```sql
-- 全員が全予約を閲覧可能（空き状況確認のため）
CREATE POLICY "reservations_select" ON reservations FOR SELECT USING (true);

-- ログインユーザーのみ予約作成可能
CREATE POLICY "reservations_insert" ON reservations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 自分の予約のみ更新可能
CREATE POLICY "reservations_update" ON reservations FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 自分の予約のみ削除可能
CREATE POLICY "reservations_delete" ON reservations FOR DELETE
  USING (auth.uid() = user_id);
```

---

## 4. API設計

### 4.1 認証API（Supabase Auth）

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| POST | `/auth/v1/token?grant_type=id_token` | Google OAuth認証 |
| POST | `/auth/v1/logout` | ログアウト |
| GET | `/auth/v1/user` | ログイン中のユーザー情報取得 |

**実装例**:
```typescript
// src/lib/supabase/auth.ts
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'

export async function signInWithGoogle() {
  const supabase = createClientComponentClient()
  await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${window.location.origin}/dashboard`,
    },
  })
}

export async function signOut() {
  const supabase = createClientComponentClient()
  await supabase.auth.signOut()
}
```

---

### 4.2 予約API（Supabase Client経由）

| 操作 | メソッド | 説明 | 実装 |
|-----|---------|------|------|
| 予約一覧取得 | SELECT | 指定期間の全予約を取得 | `supabase.from('reservations').select('*, meeting_rooms(*)').gte('start_time', start).lte('end_time', end)` |
| 予約作成 | INSERT | 新規予約を作成 | `supabase.from('reservations').insert({ room_id, user_id, start_time, end_time, title })` |
| 予約更新 | UPDATE | 既存予約を更新 | `supabase.from('reservations').update({ start_time, end_time, title }).eq('id', id)` |
| 予約削除 | DELETE | 予約をキャンセル | `supabase.from('reservations').delete().eq('id', id)` |

**実装例**:
```typescript
// src/lib/supabase/queries.ts
export async function getReservations(startDate: Date, endDate: Date) {
  const supabase = createClientComponentClient()
  const { data, error } = await supabase
    .from('reservations')
    .select('*, meeting_rooms(*)')
    .gte('start_time', startDate.toISOString())
    .lte('end_time', endDate.toISOString())
    .order('start_time')

  if (error) throw error
  return data
}

export async function createReservation(reservation: {
  room_id: string
  start_time: string
  end_time: string
  title: string
  description?: string
}) {
  const supabase = createClientComponentClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('Not authenticated')

  const { data, error } = await supabase
    .from('reservations')
    .insert({ ...reservation, user_id: user.id })
    .select()
    .single()

  if (error) throw error
  return data
}
```

---

## 5. UI/UX設計

### 5.1 デザイントークン（Tailwind設定）

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',  // メインブルー
          600: '#2563eb',
          700: '#1d4ed8',
        },
        roomA: '#3B82F6',
        roomB: '#06B6D4',
        roomC: '#0EA5E9',
      },
    },
  },
}
```

### 5.2 画面構成

#### 5.2.1 ログインページ (`/`)
- Googleログインボタン（青基調、center配置）
- アプリ名・説明

#### 5.2.2 ダッシュボード (`/dashboard`)
- ヘッダー: ロゴ、ユーザー名、ログアウトボタン
- 会議室選択タブ（A/B/C）
- カレンダービュー（週表示）
- 予約一覧（自分の予約のみフィルタ可能）

#### 5.2.3 予約作成・編集 (`/booking`)
- 会議室選択
- 日時選択（開始・終了）
- タイトル・備考入力
- 保存/キャンセルボタン

---

## 6. コーディング規約

### 6.1 TypeScript

| 項目 | ルール | 理由 |
|-----|--------|------|
| Strict Mode | `"strict": true` 必須 | 型安全性の最大化 |
| `any` 型 | **使用禁止** | 型安全性の喪失を防ぐ |
| 型定義 | `src/lib/types/index.ts` に集約 | 型の再利用性向上 |
| 関数戻り値 | 明示的に型を記述 | 可読性向上 |

**例**:
```typescript
// ❌ Bad
function getUser(id) {
  return fetch(`/api/users/${id}`)
}

// ✅ Good
async function getUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`)
  return res.json()
}
```

---

### 6.2 React/Next.js

| 項目 | ルール | 理由 |
|-----|--------|------|
| コンポーネント | 関数コンポーネント + Hooks | 現代的な書き方 |
| ファイル命名 | PascalCase（例: `RoomCard.tsx`） | コンポーネントの識別 |
| Client Component | `'use client'` を明記 | SSR/CSRの明確化 |
| Server Component | デフォルト（指定不要） | パフォーマンス最適化 |

**例**:
```typescript
// src/components/room/RoomCard.tsx
'use client'

import { MeetingRoom } from '@/lib/types'

interface RoomCardProps {
  room: MeetingRoom
  onClick: (roomId: string) => void
}

export function RoomCard({ room, onClick }: RoomCardProps) {
  return (
    <div onClick={() => onClick(room.id)}>
      <h3>{room.name}</h3>
      <p>定員: {room.capacity}名</p>
    </div>
  )
}
```

---

### 6.3 Supabase

| 項目 | ルール | 理由 |
|-----|--------|------|
| クライアント初期化 | `createClientComponentClient` 使用 | App Routerとの互換性 |
| エラーハンドリング | `try-catch` + ユーザーフレンドリーなメッセージ | UX向上 |
| RLS | 必ずRLSを有効化 | セキュリティ |

**例**:
```typescript
// src/lib/supabase/client.ts
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { Database } from './database.types'

export function createClient() {
  return createClientComponentClient<Database>()
}
```

---

### 6.4 CSS/Tailwind

| 項目 | ルール | 理由 |
|-----|--------|------|
| Tailwind優先 | カスタムCSSは最小限 | 一貫性の保持 |
| レスポンシブ | モバイルファースト設計 | ユーザビリティ |
| カラー | `primary-500` 等を使用 | デザイントークン統一 |

---

### 6.5 Git

| 項目 | ルール |
|-----|--------|
| ブランチ命名 | `feature/xxxx`, `fix/xxxx` |
| コミットメッセージ | `feat: 機能追加`, `fix: バグ修正`, `docs: ドキュメント` |
| コミット単位 | 1機能 = 1コミット |

---

## 7. セキュリティ考慮事項

| 項目 | 対策 |
|-----|------|
| 認証 | Supabase Auth（Google OAuth）による認証 |
| 認可 | Row Level Security (RLS) による権限制御 |
| XSS | Next.jsのデフォルトエスケープ機能 |
| CSRF | Supabase SDKが自動対応 |
| 環境変数 | `.env.local` をGit追跡対象外に設定 |

---

## 8. 開発フロー

### 8.1 初期セットアップ
1. Next.jsプロジェクト作成
2. Supabaseプロジェクト作成
3. 環境変数設定
4. DBマイグレーション実行
5. Google OAuth設定

### 8.2 開発順序（推奨）
1. **DB/Infra Engineer**: Supabase設定 + マイグレーション
2. **UI/UX Designer**: デザインシステム構築（Tailwind設定、カラー定義）
3. **Backend Specialist**: Supabase Clientラッパー実装
4. **Frontend Specialist**: 認証フロー + ダッシュボード実装

※ 2と3は並列実行可能

---

## 9. 非機能要件

| 項目 | 目標値 |
|-----|--------|
| ページ読み込み速度 | < 2秒 |
| レスポンシブ対応 | スマホ/タブレット/PC |
| ブラウザ対応 | Chrome, Safari, Edge 最新版 |
| 可用性 | Vercel + Supabaseの標準SLA |

---

## 10. 将来拡張案（MVP外）

- 定期予約機能
- 会議室の設備情報表示
- メール通知
- 管理者画面（会議室追加・削除）
- 利用統計ダッシュボード

---

## 11. 成果物チェックリスト

- [x] システムアーキテクチャ図
- [x] ディレクトリ構成
- [x] DB設計（テーブル定義）
- [x] API設計（エンドポイント一覧）
- [x] コーディング規約
- [x] セキュリティ考慮事項
- [x] 開発フロー

---

**技術設計完了。実装フェーズに進む準備が整いました。**
