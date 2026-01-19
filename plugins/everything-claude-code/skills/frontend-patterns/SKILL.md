# Frontend Patterns Skill

フロントエンド開発のパターンとベストプラクティス。

## React コンポーネント設計

### 関数コンポーネント

```typescript
interface UserCardProps {
  user: User;
  onEdit?: (id: string) => void;
}

export function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div className="user-card">
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      {onEdit && (
        <button onClick={() => onEdit(user.id)}>Edit</button>
      )}
    </div>
  );
}
```

### コンポーネント分割の原則

```
components/
├── ui/           # 汎用UIコンポーネント
│   ├── Button.tsx
│   ├── Input.tsx
│   └── Modal.tsx
├── features/     # 機能固有コンポーネント
│   └── user/
│       ├── UserCard.tsx
│       ├── UserList.tsx
│       └── UserForm.tsx
└── layouts/      # レイアウトコンポーネント
    ├── Header.tsx
    └── Sidebar.tsx
```

## 状態管理

### ローカル状態（useState）

```typescript
// 単純な状態
const [isOpen, setIsOpen] = useState(false);

// オブジェクト状態
const [form, setForm] = useState<FormState>({
  name: '',
  email: ''
});

const updateField = (field: keyof FormState, value: string) => {
  setForm(prev => ({ ...prev, [field]: value }));
};
```

### グローバル状態（Zustand）

```typescript
interface UserStore {
  user: User | null;
  isLoading: boolean;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
}

export const useUserStore = create<UserStore>((set) => ({
  user: null,
  isLoading: false,
  login: async (credentials) => {
    set({ isLoading: true });
    const user = await authApi.login(credentials);
    set({ user, isLoading: false });
  },
  logout: () => set({ user: null })
}));
```

### サーバー状態（TanStack Query）

```typescript
// データ取得
const { data, isLoading, error } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId)
});

// データ更新
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] });
  }
});
```

## カスタムフック

### データフェッチフック

```typescript
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    setIsLoading(true);
    fetchUser(userId)
      .then(data => !cancelled && setUser(data))
      .catch(err => !cancelled && setError(err))
      .finally(() => !cancelled && setIsLoading(false));

    return () => { cancelled = true; };
  }, [userId]);

  return { user, isLoading, error };
}
```

### フォームフック

```typescript
function useForm<T extends Record<string, unknown>>(initialValues: T) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});

  const handleChange = (field: keyof T, value: T[keyof T]) => {
    setValues(prev => ({ ...prev, [field]: value }));
    setErrors(prev => ({ ...prev, [field]: undefined }));
  };

  const reset = () => setValues(initialValues);

  return { values, errors, handleChange, setErrors, reset };
}
```

## スタイリング（Tailwind CSS）

### コンポーネントスタイル

```typescript
// バリアント対応ボタン
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
}

const variants = {
  primary: 'bg-blue-500 hover:bg-blue-600 text-white',
  secondary: 'bg-gray-200 hover:bg-gray-300 text-gray-800',
  danger: 'bg-red-500 hover:bg-red-600 text-white'
};

const sizes = {
  sm: 'px-2 py-1 text-sm',
  md: 'px-4 py-2',
  lg: 'px-6 py-3 text-lg'
};

export function Button({
  variant = 'primary',
  size = 'md',
  children
}: ButtonProps) {
  return (
    <button className={`rounded ${variants[variant]} ${sizes[size]}`}>
      {children}
    </button>
  );
}
```

## パフォーマンス最適化

### メモ化

```typescript
// コンポーネントのメモ化
const UserCard = memo(function UserCard({ user }: Props) {
  return <div>{user.name}</div>;
});

// 計算結果のメモ化
const sortedUsers = useMemo(
  () => users.sort((a, b) => a.name.localeCompare(b.name)),
  [users]
);

// コールバックのメモ化
const handleClick = useCallback(
  (id: string) => { onSelect(id); },
  [onSelect]
);
```

### 遅延読み込み

```typescript
// コンポーネントの遅延読み込み
const UserProfile = lazy(() => import('./UserProfile'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <UserProfile />
    </Suspense>
  );
}
```

## アクセシビリティ

```typescript
// キーボードナビゲーション
<button
  onClick={handleClick}
  onKeyDown={(e) => e.key === 'Enter' && handleClick()}
  tabIndex={0}
  aria-label="Close modal"
>
  ×
</button>

// スクリーンリーダー対応
<div role="alert" aria-live="polite">
  {errorMessage}
</div>
```
