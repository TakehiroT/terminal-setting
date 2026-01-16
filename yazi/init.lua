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

-- ステータスバーにチートシートを表示（中央）
function Status:cheatsheet()
  local keys = {
    { key = "x", desc = "cut" },
    { key = "y", desc = "copy" },
    { key = "p", desc = "paste" },
    { key = "d", desc = "del" },
    { key = "r", desc = "rename" },
    { key = "a", desc = "new" },
    { key = "SPC", desc = "select" },
    { key = "/", desc = "search" },
    { key = "O", desc = "Finder" },
  }

  local spans = {}
  for i, item in ipairs(keys) do
    if i > 1 then
      table.insert(spans, ui.Span(" "):fg("darkgray"))
    end
    table.insert(spans, ui.Span(item.key):fg("cyan"):bold())
    table.insert(spans, ui.Span(":" .. item.desc):fg("gray"))
  end

  return ui.Line(spans)
end

local old_redraw = Status.redraw
function Status:redraw()
  local result = old_redraw(self)
  local center = self:cheatsheet()
  table.insert(result, ui.Line(center):area(self._area):align(ui.Align.CENTER))
  return result
end
