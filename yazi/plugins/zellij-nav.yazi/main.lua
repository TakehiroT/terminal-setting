-- Terminal連携プラグイン for Yazi
-- tmux/zellij両対応（環境変数で自動判別）

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

-- 環境判別
local function is_tmux()
    return os.getenv("TMUX") ~= nil
end

local function is_zellij()
    return os.getenv("ZELLIJ") ~= nil
end

-- tmux用: termペイン同期
local function sync_term_dir_tmux(cwd)
    -- スペースや特殊文字をエスケープ
    local escaped_cwd = cwd:gsub("([\" \\$`])", "\\%1")
    -- tmuxのペイン2（下部ターミナル）にcdを送信
    local cmd = string.format(
        'tmux send-keys -t :.2 C-c ; sleep 0.03 ; tmux send-keys -t :.2 "cd \\"%s\\"" Enter',
        escaped_cwd
    )
    os.execute(cmd .. " &")
end

-- zellij用: termペイン同期
local function sync_term_dir_zellij(cwd)
    local escaped_cwd = cwd:gsub("'", "'\\''")
    local cmd = string.format(
        "zellij action focus-next-pane && " ..
        "zellij action write 3 && " ..
        "sleep 0.03 && " ..
        "zellij action write-chars $'cd \\'%s\\'\\n' && " ..
        "zellij action focus-previous-pane",
        escaped_cwd
    )
    os.execute(cmd .. " &")
end

local function sync_term_dir(cwd)
    if is_tmux() then
        sync_term_dir_tmux(cwd)
    elseif is_zellij() then
        sync_term_dir_zellij(cwd)
    end
end

return {
    setup = function()
        -- ディレクトリ変更時にtermを同期（tmux/zellij両対応）
        if is_tmux() or is_zellij() then
            ps.sub("cd", function()
                local cwd = get_cwd_sync()
                if cwd then
                    sync_term_dir(cwd)
                end
            end)
        end
    end,

    entry = function(self, job)
        local action = job.args[1]

        if is_tmux() then
            -- tmux版
            if action == "edit" then
                local path = get_path_sync()
                if not path then return end
                local escaped_path = path:gsub("'", "'\\''")
                -- 新しいtmuxウィンドウでnvimを起動
                local cmd = string.format("tmux new-window -n 'nvim' nvim '%s'", escaped_path)
                os.execute(cmd)
            elseif action == "git" then
                local cwd = get_cwd_sync()
                if not cwd then return end
                local escaped_cwd = cwd:gsub("'", "'\\''")
                -- Gitタブに移動
                os.execute("tmux select-window -t :2")
            elseif action == "sync" then
                local cwd = get_cwd_sync()
                if cwd then
                    sync_term_dir_tmux(cwd)
                end
            end
        elseif is_zellij() then
            -- zellij版
            local cmd
            if action == "preview" then
                local path = get_path_sync()
                if not path then return end
                local escaped_path = path:gsub("'", "'\\''")

                local preview_cmd
                if path:match("%.md$") or path:match("%.markdown$") then
                    preview_cmd = string.format("glow -p \\'%s\\'", escaped_path)
                else
                    preview_cmd = string.format("bat --paging=never --style=numbers --color=always \\'%s\\'", escaped_path)
                end

                cmd = string.format(
                    "zellij action focus-next-pane && " ..
                    "zellij action write 113 && " ..
                    "zellij action write 3 && " ..
                    "sleep 0.05 && " ..
                    "zellij action write-chars $'clear && %s; read\\n' && " ..
                    "zellij action focus-previous-pane",
                    preview_cmd
                )
            elseif action == "edit" then
                local path = get_path_sync()
                if not path then return end
                local escaped_path = path:gsub("'", "'\\''")
                cmd = string.format("zellij run -f -- nvim '%s'", escaped_path)
            elseif action == "git" then
                local cwd = get_cwd_sync()
                if not cwd then return end
                local escaped_cwd = cwd:gsub("'", "'\\''")
                cmd = string.format("zellij run -f --cwd '%s' -- lazygit", escaped_cwd)
            elseif action == "sync" then
                local cwd = get_cwd_sync()
                if cwd then
                    sync_term_dir_zellij(cwd)
                end
                return
            else
                return
            end

            if cmd then
                os.execute(cmd)
            end
        end
    end,
}
