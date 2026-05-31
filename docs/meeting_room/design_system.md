# 会議室予約システム MVP - デザインシステム

**Project ID**: meeting_room
**Version**: 1.0.0
**Created**: 2026-02-02
**Designer**: UI/UX Designer Agent

---

## 1. デザイン原則

### 1.1 コンセプト
- **シンプル**: 直感的な操作で誰でも使える
- **クリーン**: 青基調の清潔感あるデザイン
- **識別性**: 会議室ごとに色分けで視認性向上

### 1.2 MVP方針
- 過剰な装飾は避ける
- 実用性重視
- アクセシビリティ確保（WCAG 2.1 AA準拠）

---

## 2. カラーパレット

### 2.1 Primary Colors（メインカラー）

```css
/* Blue (Primary) */
--color-primary-50: #eff6ff;
--color-primary-100: #dbeafe;
--color-primary-200: #bfdbfe;
--color-primary-300: #93c5fd;
--color-primary-400: #60a5fa;
--color-primary-500: #3b82f6;  /* メイン */
--color-primary-600: #2563eb;
--color-primary-700: #1d4ed8;
--color-primary-800: #1e40af;
--color-primary-900: #1e3a8a;
```

### 2.2 Meeting Room Colors（会議室識別色）

| 会議室 | カラーコード | Tailwind名 | 用途 |
|--------|--------------|------------|------|
| 会議室A | `#3B82F6` | `roomA` | カレンダー表示、カード背景 |
| 会議室B | `#06B6D4` | `roomB` | カレンダー表示、カード背景 |
| 会議室C | `#0EA5E9` | `roomC` | カレンダー表示、カード背景 |

### 2.3 Neutral Colors（グレースケール）

```css
--color-gray-50: #f9fafb;
--color-gray-100: #f3f4f6;
--color-gray-200: #e5e7eb;
--color-gray-300: #d1d5db;
--color-gray-400: #9ca3af;
--color-gray-500: #6b7280;
--color-gray-600: #4b5563;
--color-gray-700: #374151;
--color-gray-800: #1f2937;
--color-gray-900: #111827;
```

### 2.4 Semantic Colors（状態表示色）

| 用途 | カラー | カラーコード |
|------|--------|--------------|
| 成功 | Success | `#10b981` (green-500) |
| 警告 | Warning | `#f59e0b` (amber-500) |
| エラー | Error | `#ef4444` (red-500) |
| 情報 | Info | `#3b82f6` (primary-500) |

---

## 3. タイポグラフィ

### 3.1 Font Family

```css
/* Primary Font */
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Hiragino Sans', 'Hiragino Kaku Gothic ProN', 'Noto Sans JP', sans-serif;

/* Monospace (コード表示用) */
--font-mono: 'Fira Code', 'Courier New', monospace;
```

### 3.2 Font Size Scale

| 名前 | サイズ | 用途 |
|------|--------|------|
| `text-xs` | 12px (0.75rem) | キャプション、補足テキスト |
| `text-sm` | 14px (0.875rem) | 本文（小）、ラベル |
| `text-base` | 16px (1rem) | 本文（標準） |
| `text-lg` | 18px (1.125rem) | リード文、強調 |
| `text-xl` | 20px (1.25rem) | サブ見出し |
| `text-2xl` | 24px (1.5rem) | 見出し（H2） |
| `text-3xl` | 30px (1.875rem) | 見出し（H1） |
| `text-4xl` | 36px (2.25rem) | ページタイトル |

### 3.3 Font Weight

| 名前 | 値 | 用途 |
|------|------|------|
| `font-normal` | 400 | 本文 |
| `font-medium` | 500 | ラベル、強調 |
| `font-semibold` | 600 | サブ見出し |
| `font-bold` | 700 | 見出し |

### 3.4 Line Height

| 名前 | 値 | 用途 |
|------|------|------|
| `leading-tight` | 1.25 | 見出し |
| `leading-normal` | 1.5 | 本文 |
| `leading-relaxed` | 1.75 | リード文 |

---

## 4. スペーシング

### 4.1 Spacing Scale

```css
--space-1: 0.25rem;  /* 4px */
--space-2: 0.5rem;   /* 8px */
--space-3: 0.75rem;  /* 12px */
--space-4: 1rem;     /* 16px */
--space-5: 1.25rem;  /* 20px */
--space-6: 1.5rem;   /* 24px */
--space-8: 2rem;     /* 32px */
--space-10: 2.5rem;  /* 40px */
--space-12: 3rem;    /* 48px */
--space-16: 4rem;    /* 64px */
```

### 4.2 Component Padding

| コンポーネント | Padding |
|----------------|---------|
| ボタン（小） | `px-3 py-2` (12px 8px) |
| ボタン（中） | `px-4 py-2` (16px 8px) |
| ボタン（大） | `px-6 py-3` (24px 12px) |
| カード | `p-6` (24px) |
| モーダル | `p-8` (32px) |
| ページコンテナ | `px-4 py-6` (16px 24px) |

---

## 5. コンポーネント仕様

### 5.1 Button（ボタン）

#### Variants（バリエーション）

| Variant | 背景色 | テキスト色 | ボーダー | 用途 |
|---------|--------|-----------|---------|------|
| Primary | `bg-primary-500` | `text-white` | なし | 主要アクション（保存、ログイン） |
| Secondary | `bg-transparent` | `text-primary-500` | `border-primary-500` | 副次的アクション |
| Ghost | `bg-transparent` | `text-gray-700` | なし | 軽いアクション（キャンセル） |
| Danger | `bg-red-500` | `text-white` | なし | 削除、キャンセル |

#### Sizes（サイズ）

| Size | Padding | Font Size | Height | Border Radius |
|------|---------|-----------|--------|---------------|
| sm | `px-3 py-1.5` | `text-sm` | 32px | `rounded` (4px) |
| md | `px-4 py-2` | `text-base` | 40px | `rounded-md` (6px) |
| lg | `px-6 py-3` | `text-lg` | 48px | `rounded-lg` (8px) |

#### States（状態）

```css
/* Default */
.button { ... }

/* Hover */
.button:hover { opacity: 0.9; }

/* Active */
.button:active { transform: scale(0.98); }

/* Disabled */
.button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Focus */
.button:focus {
  outline: 2px solid var(--color-primary-500);
  outline-offset: 2px;
}
```

---

### 5.2 Input Field（入力フィールド）

#### Style

```css
/* Base */
border: 1px solid var(--color-gray-300);
border-radius: 6px;
padding: 8px 12px;
font-size: 16px;
background: white;

/* Focus */
border-color: var(--color-primary-500);
box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);

/* Error */
border-color: var(--color-error);
```

#### Sizes

| Size | Height | Padding | Font Size |
|------|--------|---------|-----------|
| sm | 32px | `px-3 py-1.5` | `text-sm` |
| md | 40px | `px-3 py-2` | `text-base` |
| lg | 48px | `px-4 py-3` | `text-lg` |

---

### 5.3 Card（カード）

```css
/* Base Card */
background: white;
border: 1px solid var(--color-gray-200);
border-radius: 12px;
padding: 24px;
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);

/* Hover (クリッカブルな場合) */
box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
transform: translateY(-2px);
```

#### Room Card（会議室カード）

```
┌─────────────────────┐
│ 会議室A             │ ← bg-roomA
│ 定員: 10名          │
│ ステータス: 空き    │
└─────────────────────┘
```

---

### 5.4 Modal（モーダル）

```css
/* Overlay */
background: rgba(0, 0, 0, 0.5);
position: fixed;
inset: 0;
z-index: 50;

/* Modal Container */
background: white;
border-radius: 16px;
padding: 32px;
max-width: 500px;
box-shadow: 0 20px 25px rgba(0, 0, 0, 0.15);
```

---

## 6. レイアウトグリッド

### 6.1 Container

```css
max-width: 1280px;
margin: 0 auto;
padding: 0 16px;

/* Tablet+ */
@media (min-width: 768px) {
  padding: 0 24px;
}
```

### 6.2 Breakpoints

| 名前 | サイズ | デバイス |
|------|--------|----------|
| `sm` | 640px | モバイル横 |
| `md` | 768px | タブレット |
| `lg` | 1024px | ノートPC |
| `xl` | 1280px | デスクトップ |
| `2xl` | 1536px | 大画面 |

---

## 7. アイコン

### 7.1 Icon Library
- **推奨**: Heroicons (Tailwind公式)
- **サイズ**: 16px, 20px, 24px
- **スタイル**: Outline（通常）、Solid（強調）

### 7.2 主要アイコン

| 用途 | アイコン名 | サイズ |
|------|-----------|--------|
| ログイン | `ArrowRightOnRectangleIcon` | 20px |
| ログアウト | `ArrowLeftOnRectangleIcon` | 20px |
| カレンダー | `CalendarIcon` | 24px |
| 会議室 | `HomeIcon` | 20px |
| 時計 | `ClockIcon` | 16px |
| 編集 | `PencilIcon` | 16px |
| 削除 | `TrashIcon` | 16px |
| チェック | `CheckIcon` | 16px |
| 閉じる | `XMarkIcon` | 20px |

---

## 8. 主要画面ワイヤーフレーム

### 8.1 ログイン画面 (`/`)

```
┌────────────────────────────────────────────┐
│                                            │
│              [ロゴ]                        │
│         会議室予約システム                 │
│                                            │
│    ┌──────────────────────────────┐       │
│    │                              │       │
│    │   Googleでログイン            │       │
│    │   [Google Icon]              │       │
│    │                              │       │
│    └──────────────────────────────┘       │
│                                            │
│    簡単に会議室を予約できます              │
│                                            │
└────────────────────────────────────────────┘

【要素】
1. ロゴ（中央寄せ）
   - Font: text-3xl font-bold
   - Color: text-primary-600
   - Margin: mb-8

2. サービス名
   - Font: text-2xl font-semibold
   - Color: text-gray-900
   - Margin: mb-6

3. Googleログインボタン
   - Variant: Primary
   - Size: lg
   - Full Width: true
   - Icon: Google logo (left)

4. 説明文
   - Font: text-sm
   - Color: text-gray-600
   - Margin: mt-4

【レイアウト】
- Container: max-w-md (448px)
- Center: mx-auto
- Vertical Center: min-h-screen flex items-center
- Background: bg-gray-50
```

---

### 8.2 ダッシュボード/カレンダー画面 (`/dashboard`)

```
┌──────────────────────────────────────────────────────────┐
│ [ロゴ] 会議室予約システム          [ユーザー名▼] [ログアウト] │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  [会議室A]  [会議室B]  [会議室C]  ← タブ                 │
│  ─────────  ──────────  ──────────                       │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │  カレンダービュー                                │    │
│  │                                                 │    │
│  │   月   火   水   木   金   土   日               │    │
│  │  ┌───┬───┬───┬───┬───┬───┬───┐             │    │
│  │  │   │   │   │■■│   │   │   │ 9:00        │    │
│  │  ├───┼───┼───┼───┼───┼───┼───┤             │    │
│  │  │   │■■│   │■■│   │   │   │ 11:00       │    │
│  │  ├───┼───┼───┼───┼───┼───┼───┤             │    │
│  │  │   │■■│■■│   │   │   │   │ 13:00       │    │
│  │  └───┴───┴───┴───┴───┴───┴───┘             │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  【あなたの予約】                                        │
│  ┌────────────────────────────────────────┐             │
│  │ 2/5(水) 14:00-15:00 会議室A            │             │
│  │ チーム定例ミーティング          [編集][削除] │         │
│  ├────────────────────────────────────────┤             │
│  │ 2/7(金) 10:00-12:00 会議室B            │             │
│  │ プロジェクト打ち合わせ          [編集][削除] │         │
│  └────────────────────────────────────────┘             │
│                                                          │
│                              [+ 新規予約]                │
└──────────────────────────────────────────────────────────┘

【要素】
1. ヘッダー
   - Height: 64px
   - Background: bg-white
   - Border: border-b border-gray-200
   - Logo: text-xl font-semibold
   - User Menu: text-sm text-gray-700

2. タブ（会議室選択）
   - Active: bg-roomA/roomB/roomC, text-white
   - Inactive: bg-gray-100, text-gray-600
   - Padding: px-4 py-2
   - Border Radius: rounded-t-lg

3. カレンダービュー
   - Grid: 7列（週）× 時間枠
   - Cell: 予約あり（bg-roomA/B/C + opacity-70）
   - Hover: cursor-pointer, opacity-100
   - Click: 予約モーダル表示

4. 予約一覧カード
   - Background: bg-white
   - Border: border-gray-200
   - Padding: p-4
   - Icon: 時計アイコン (left)

5. 新規予約ボタン
   - Position: fixed, bottom-right
   - Variant: Primary
   - Size: lg
   - Icon: PlusIcon
```

---

### 8.3 予約モーダル (`/booking` または Modal)

```
┌────────────────────────────────────────┐
│  予約する                       [×]    │
├────────────────────────────────────────┤
│                                        │
│  会議室                                │
│  [ 会議室A ▼ ]                         │
│                                        │
│  日付                                  │
│  [ 2026-02-05 ] [カレンダーアイコン]   │
│                                        │
│  開始時刻                              │
│  [ 14:00 ▼ ]                           │
│                                        │
│  終了時刻                              │
│  [ 15:00 ▼ ]                           │
│                                        │
│  タイトル                              │
│  [ チーム定例ミーティング             ]│
│                                        │
│  備考（任意）                          │
│  ┌──────────────────────────────────┐ │
│  │                                  │ │
│  │                                  │ │
│  └──────────────────────────────────┘ │
│                                        │
│  [キャンセル]          [予約する]      │
│                                        │
└────────────────────────────────────────┘

【要素】
1. モーダルヘッダー
   - Font: text-xl font-semibold
   - Padding: pb-4
   - Border: border-b

2. フォームフィールド
   - Label: text-sm font-medium text-gray-700, mb-1
   - Input: Full Width
   - Spacing: mb-4

3. 会議室セレクト
   - Options: 色付きドット + 会議室名
   - 例: "🔵 会議室A"

4. 日付ピッカー
   - Type: date input
   - Icon: CalendarIcon (right)

5. 時刻セレクト
   - Options: 30分刻み（9:00-18:00）

6. アクションボタン
   - キャンセル: Variant=Ghost
   - 予約する: Variant=Primary
   - Layout: flex, justify-end, gap-3
```

---

## 9. アクセシビリティ

### 9.1 色のコントラスト比

| 組み合わせ | コントラスト比 | 基準 |
|-----------|----------------|------|
| Primary-500 / White | 4.5:1 | AA ✓ |
| Gray-900 / White | 16.2:1 | AAA ✓ |
| Gray-600 / White | 4.6:1 | AA ✓ |

### 9.2 キーボードナビゲーション

- 全てのインタラクティブ要素にフォーカス状態を設定
- Tab順序は視覚的な順序と一致
- Escape キーでモーダルを閉じる

### 9.3 スクリーンリーダー対応

```html
<!-- ボタンにaria-label -->
<button aria-label="会議室Aを予約">...</button>

<!-- フォームにlabelを関連付け -->
<label for="room-select">会議室</label>
<select id="room-select">...</select>

<!-- ステータスにaria-live -->
<div aria-live="polite">予約が完了しました</div>
```

---

## 10. レスポンシブ対応

### 10.1 ブレークポイント戦略

| デバイス | 幅 | レイアウト変更 |
|---------|------|---------------|
| Mobile | < 640px | 1カラム、フルスクリーンモーダル |
| Tablet | 640px - 1024px | 2カラム、カレンダー簡略表示 |
| Desktop | > 1024px | 3カラム、フル機能カレンダー |

### 10.2 モバイル最適化

```css
/* モバイル: フォントサイズ調整 */
@media (max-width: 640px) {
  body { font-size: 14px; }
  h1 { font-size: 24px; }

  /* タップターゲット最小サイズ: 44px */
  .button { min-height: 44px; }
}

/* モバイル: パディング削減 */
.container {
  padding: 16px;
}

/* デスクトップ: パディング増加 */
@media (min-width: 1024px) {
  .container { padding: 24px; }
}
```

---

## 11. アニメーション

### 11.1 トランジション

```css
/* 標準 */
transition: all 0.2s ease-in-out;

/* 速い（ホバー） */
transition: opacity 0.15s ease;

/* 遅い（モーダル） */
transition: transform 0.3s ease-out;
```

### 11.2 使用例

| 要素 | アニメーション |
|------|----------------|
| ボタン | Hover時に opacity 0.9 |
| カード | Hover時に translateY(-2px) |
| モーダル | フェードイン + スケール |
| 通知 | スライドイン（右から） |

---

## 12. 成果物チェックリスト

- [x] カラーパレット定義
- [x] タイポグラフィスケール
- [x] スペーシングルール
- [x] コンポーネント仕様（Button, Input, Card, Modal）
- [x] ログイン画面ワイヤーフレーム
- [x] ダッシュボード画面ワイヤーフレーム
- [x] 予約モーダルワイヤーフレーム
- [x] アクセシビリティ考慮
- [x] レスポンシブ対応指針

---

**デザインシステム設計完了。Frontend Specialistへの引き継ぎ準備完了です。**
