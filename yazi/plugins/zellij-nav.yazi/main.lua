-- Zellij連携プラグイン for Yazi
-- 右上のpreviewペインでbat/nvim/lazygitを実行
-- termペインをYaziのディレクトリに同期

local function get_path()
    local h = cx.active.current.hovered
    if h then
        return tostring(h.url)
    end
    return nil
end

local function get_cwd()
    return tostring(cx.active.current.cwd)
end

local get_path_sync = ya.sync(get_path)
local get_cwd_sync = ya.sync(get_cwd)

local function sync_term_dir(cwd)
    local escaped_cwd = cwd:gsub("'", "'\\''")
    -- preview → term の順でフォーカス移動し、cdを送信して戻る
    local cmd = string.format(
        "zellij action focus-next-pane && " ..  -- Yazi → preview
        "zellij action focus-next-pane && " ..  -- preview → term
        "zellij action write 3 && " ..          -- Ctrl+C
        "sleep 0.03 && " ..
        "zellij action write-chars $'cd \\'%s\\'\\n' && " ..
        "zellij action focus-previous-pane && " ..  -- term → preview
        "zellij action focus-previous-pane",        -- preview → Yazi
        escaped_cwd
    )
    os.execute(cmd .. " &")  -- バックグラウンドで実行
end

return {
    setup = function()
        -- ディレクトリ変更時にtermを同期
        ps.sub("cd", function()
            local cwd = get_cwd_sync()
            if cwd then
                sync_term_dir(cwd)
            end
        end)
    end,

    entry = function(self, job)
        local action = job.args[1]

        local cmd
        if action == "preview" then
            local path = get_path_sync()
            if not path then return end
            local escaped_path = path:gsub("'", "'\\''")

            -- Markdownファイルはglowで表示、それ以外はbat
            local preview_cmd
            if path:match("%.md$") or path:match("%.markdown$") then
                preview_cmd = string.format("glow -p \\'%s\\'", escaped_path)
            else
                preview_cmd = string.format("bat --paging=never --style=numbers --color=always \\'%s\\'", escaped_path)
            end

            cmd = string.format(
                "zellij action focus-next-pane && " ..
                "zellij action write 113 && " ..  -- 'q' でページャー終了
                "zellij action write 3 && " ..    -- Ctrl+C
                "sleep 0.05 && " ..
                "zellij action write-chars $'clear && %s; read\\n' && " ..
                "zellij action focus-previous-pane",
                preview_cmd
            )
        elseif action == "edit" then
            local path = get_path_sync()
            if not path then return end
            local escaped_path = path:gsub("'", "'\\''")

            -- nvim終了後に自動でYaziペインにフォーカスを戻す
            cmd = string.format(
                "zellij action focus-next-pane && " ..
                "zellij action write 113 && " ..  -- 'q' でページャー終了
                "zellij action write 3 && " ..    -- Ctrl+C
                "sleep 0.05 && " ..
                "zellij action write-chars $'nvim \\'%s\\' && zellij action focus-previous-pane\\n'",
                escaped_path
            )
        elseif action == "git" then
            local cwd = get_cwd_sync()
            if not cwd then return end
            local escaped_cwd = cwd:gsub("'", "'\\''")

            -- lazygit終了後に自動でYaziペインにフォーカスを戻す
            cmd = string.format(
                "zellij action focus-next-pane && " ..
                "zellij action write 113 && " ..  -- 'q' でページャー終了
                "zellij action write 3 && " ..    -- Ctrl+C
                "sleep 0.05 && " ..
                "zellij action write-chars $'cd \\'%s\\' && lazygit && zellij action focus-previous-pane\\n'",
                escaped_cwd
            )
        elseif action == "sync" then
            -- 手動でtermを同期
            local cwd = get_cwd_sync()
            if cwd then
                sync_term_dir(cwd)
            end
            return
        else
            return
        end

        os.execute(cmd)
    end,
}
