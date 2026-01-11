local M = {}

local function get_cache_path(url, width)
	local hash = ya.hash(tostring(url) .. ":" .. tostring(width))
	return "/tmp/yazi-glow-cache-" .. hash
end

local function read_cache(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local lines = {}
	for line in file:lines() do
		lines[#lines + 1] = line .. "\n"
	end
	file:close()
	return lines
end

local function write_cache(path, content)
	local file = io.open(path, "w")
	if file then
		file:write(content)
		file:close()
	end
end

local function render_glow(url, width, cache_path)
	local child = Command("glow")
		:arg("--style")
		:arg("dark")
		:arg("--width")
		:arg(tostring(width))
		:arg(tostring(url))
		:env("CLICOLOR_FORCE", "1")
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return nil
	end

	local lines = {}
	local content = ""
	while true do
		local line, event = child:read_line()
		if event ~= 0 then
			break
		end
		lines[#lines + 1] = line
		content = content .. line
	end
	child:start_kill()

	-- キャッシュに保存
	write_cache(cache_path, content)

	return lines
end

function M:peek(job)
	local cache_path = get_cache_path(job.file.url, job.area.w)

	-- キャッシュから読み込み試行
	local lines = read_cache(cache_path)

	-- キャッシュになければレンダリング
	if not lines or #lines == 0 then
		lines = render_glow(job.file.url, job.area.w, cache_path)
	end

	if not lines or #lines == 0 then
		ya.preview_widget(job, ui.Text("glow failed"):area(job.area))
		return
	end

	-- 表示範囲を計算
	local start_line = job.skip + 1
	local end_line = math.min(job.skip + job.area.h, #lines)

	-- 範囲外チェック
	if start_line > #lines then
		ya.mgr_emit("peek", {
			tostring(math.max(0, #lines - job.area.h)),
			only_if = job.file.url,
			upper_bound = true,
		})
		return
	end

	-- 表示する行を結合
	local display = ""
	for i = start_line, end_line do
		display = display .. (lines[i] or "")
	end

	ya.preview_widget(job, ui.Text.parse(display):area(job.area))
end

function M:seek(job)
	local h = cx.active.current.hovered
	if not h or h.url ~= job.file.url then
		return
	end

	ya.mgr_emit("peek", {
		math.max(0, cx.active.preview.skip + job.units),
		only_if = job.file.url,
	})
end

return M
