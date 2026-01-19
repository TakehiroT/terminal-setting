# Coding Standards Skill

TypeScript/JavaScript のコーディング標準ガイド。

## イミュータビリティ

### const を優先

```typescript
// ✅ Good
const users = ['alice', 'bob'];
const config = Object.freeze({ api: 'https://...' });

// ❌ Bad
let users = ['alice', 'bob'];
var config = { api: 'https://...' };
```

### スプレッド演算子で新しいオブジェクト

```typescript
// ✅ Good
const updatedUser = { ...user, name: 'New Name' };
const newArray = [...items, newItem];

// ❌ Bad
user.name = 'New Name';
items.push(newItem);
```

## 早期リターン

```typescript
// ✅ Good
function processUser(user: User | null): string {
  if (!user) return 'No user';
  if (!user.isActive) return 'Inactive';

  return `Hello, ${user.name}`;
}

// ❌ Bad
function processUser(user: User | null): string {
  if (user) {
    if (user.isActive) {
      return `Hello, ${user.name}`;
    } else {
      return 'Inactive';
    }
  } else {
    return 'No user';
  }
}
```

## 命名規則

### 変数・関数

```typescript
// ✅ Good
const isActive = true;
const userCount = 10;
const fetchUserById = async (id: string) => {};

// ❌ Bad
const flag = true;
const n = 10;
const get = async (id: string) => {};
```

### 型・インターフェース

```typescript
// ✅ Good
interface User { ... }
type UserId = string;
enum Status { Active, Inactive }

// ❌ Bad
interface IUser { ... }
type TUserId = string;
```

## マジックナンバー禁止

```typescript
// ✅ Good
const MAX_RETRY_COUNT = 3;
const HTTP_OK = 200;

if (retryCount < MAX_RETRY_COUNT) { ... }
if (response.status === HTTP_OK) { ... }

// ❌ Bad
if (retryCount < 3) { ... }
if (response.status === 200) { ... }
```

## エラーハンドリング

### Result型パターン

```typescript
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function parseJson<T>(json: string): Result<T> {
  try {
    return { success: true, data: JSON.parse(json) };
  } catch (e) {
    return { success: false, error: e as Error };
  }
}
```

### 適切なエラー伝播

```typescript
// ✅ Good
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/users/${id}`);
  if (!response.ok) {
    throw new ApiError(`Failed to fetch user: ${response.status}`);
  }
  return response.json();
}

// ❌ Bad
async function fetchUser(id: string): Promise<User | null> {
  try {
    const response = await fetch(`/users/${id}`);
    return response.json();
  } catch {
    return null; // エラー情報が失われる
  }
}
```

## 非同期処理

### async/await を優先

```typescript
// ✅ Good
async function fetchData() {
  const user = await fetchUser();
  const posts = await fetchPosts(user.id);
  return { user, posts };
}

// ❌ Bad
function fetchData() {
  return fetchUser()
    .then(user => fetchPosts(user.id)
      .then(posts => ({ user, posts })));
}
```

### 並列実行

```typescript
// ✅ Good（独立した処理は並列）
const [users, posts] = await Promise.all([
  fetchUsers(),
  fetchPosts()
]);

// ❌ Bad（不要な直列実行）
const users = await fetchUsers();
const posts = await fetchPosts();
```

## ファイルサイズ制限

| 項目 | 目安 |
|------|------|
| ファイル | 300行以下 |
| 関数 | 50行以下 |
| クラス | 200行以下 |
| パラメータ数 | 4個以下 |
