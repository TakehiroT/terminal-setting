-- Yazi初期化ファイル
-- プラグインのsetup関数を呼び出す

-- Gitステータスの色設定（VSCode風）
th.git = th.git or {}
th.git.modified_fg = "#d19a66"   -- オレンジ（変更）
th.git.added_fg = "#98c379"      -- 緑（追加）
th.git.deleted_fg = "#e06c75"    -- 赤（削除）
th.git.updated_fg = "#61afef"    -- 青（更新）
th.git.untracked_fg = "#7f848e"  -- グレー（未追跡）
th.git.ignored_fg = "#5c6370"    -- 暗いグレー（無視）

-- プラグイン有効化
require("git"):setup()
require("zellij-nav"):setup()
