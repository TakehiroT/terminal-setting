# Backend Patterns Skill

バックエンド開発のパターンとベストプラクティス。

## API設計

### RESTful エンドポイント

```
GET    /users          # 一覧取得
GET    /users/:id      # 単一取得
POST   /users          # 作成
PUT    /users/:id      # 全体更新
PATCH  /users/:id      # 部分更新
DELETE /users/:id      # 削除
```

### レスポンス形式

```typescript
// 成功レスポンス
{
  "data": { ... },
  "meta": {
    "total": 100,
    "page": 1,
    "perPage": 20
  }
}

// エラーレスポンス
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

## データベースパターン

### Repository パターン

```typescript
interface UserRepository {
  findById(id: string): Promise<User | null>;
  findAll(options: QueryOptions): Promise<User[]>;
  create(data: CreateUserInput): Promise<User>;
  update(id: string, data: UpdateUserInput): Promise<User>;
  delete(id: string): Promise<void>;
}

class PrismaUserRepository implements UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }
  // ...
}
```

### トランザクション

```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });
  await tx.profile.create({ data: { userId: user.id, ...profileData } });
  return user;
});
```

## 認証・認可

### JWT認証

```typescript
// トークン生成
const token = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET,
  { expiresIn: '1h' }
);

// トークン検証ミドルウェア
const authMiddleware = async (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload;
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

### RBAC（役割ベースアクセス制御）

```typescript
const requireRole = (...roles: Role[]) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
};

// 使用例
app.delete('/users/:id', authMiddleware, requireRole('admin'), deleteUser);
```

## エラーハンドリング

### カスタムエラークラス

```typescript
class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string
  ) {
    super(message);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(404, 'NOT_FOUND', `${resource} not found`);
  }
}

class ValidationError extends AppError {
  constructor(public details: ValidationDetail[]) {
    super(400, 'VALIDATION_ERROR', 'Validation failed');
  }
}
```

### グローバルエラーハンドラ

```typescript
app.use((err, req, res, next) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: { code: err.code, message: err.message }
    });
  }

  console.error(err);
  res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'Internal server error' }
  });
});
```

## ロギング

### 構造化ログ

```typescript
const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label })
  }
});

// 使用例
logger.info({ userId: user.id, action: 'login' }, 'User logged in');
logger.error({ err, requestId }, 'Request failed');
```

### リクエストログミドルウェア

```typescript
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    logger.info({
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: Date.now() - start
    });
  });
  next();
});
```

## バリデーション

### Zod による入力検証

```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().positive().optional()
});

type CreateUserInput = z.infer<typeof createUserSchema>;

// 使用例
const result = createUserSchema.safeParse(req.body);
if (!result.success) {
  throw new ValidationError(result.error.errors);
}
```
