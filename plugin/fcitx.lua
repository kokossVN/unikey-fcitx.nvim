-- check fcitx-remote (fcitx5-remote)
local fcitx_cmd = ""
if vim.fn.executable("fcitx-remote") == 1 then
	fcitx_cmd = "fcitx-remote"
elseif vim.fn.executable("fcitx5-remote") == 1 then
	fcitx_cmd = "fcitx5-remote"
else
	return
end

if os.getenv("SSH_TTY") ~= nil then
	return
end

local os_name = vim.loop.os_uname().sysname
if
	(os_name == "Linux" or os_name == "Unix")
	and os.getenv("DISPLAY") == nil
	and os.getenv("WAYLAND_DISPLAY") == nil
then
	return
end

function _Fcitx2en()
	local input_status = vim.fn.system("fcitx5-remote -n")
	if input_status ~= "keyboard-us" then
		-- input_toggle_flag means whether to restore the state of fcitx
		vim.b.input_toggle_flag = true
		-- switch to English input
		vim.fn.system(fcitx_cmd .. " -s keyboard-us")
	end
end

function _Fcitx2Unikey()
	if vim.b.input_toggle_flag == nil then
		vim.b.input_toggle_flag = false
	elseif vim.b.input_toggle_flag == true then
		-- switch to Non-Latin input
		vim.fn.system(fcitx_cmd .. " -s unikey")
		vim.b.input_toggle_flag = false
	end
end

vim.cmd([[
  augroup fcitx
    au InsertEnter * :lua _Fcitx2Unikey()
    au InsertLeave * :lua _Fcitx2en()
    au CmdlineEnter [/\?] :lua _Fcitx2NonLatin()
    au CmdlineLeave [/\?] :lua _Fcitx2en()
  augroup END
]])
