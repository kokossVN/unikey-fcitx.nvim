-- check fcitx-remote (fcitx5-remote)
local fcitx_cmd = ""
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

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
	-- input_status return curent input method
	local input_status = vim.fn.system("fcitx5-remote -n")
	if input_status ~= "keyboard-us" then
		-- switch to English
		vim.fn.system(fcitx_cmd .. " -s keyboard-us")
	end
end

function _Fcitx2Unikey()
	local input_status = vim.fn.system("fcitx5-remote -n")
	if input_status ~= "unikey" then
		-- switch to Unikey
		vim.fn.system(fcitx_cmd .. " -s unikey")
	end
end

local function _FcitxInit()
	--create augroup fcitx (but im not sure is does)
	augroup("fcitx", {
		clear = true,
	})
	if vim.g.unikey_bydefault == true then
		autocmd({ "InsertEnter" }, {
			group = "fcitx",
			callback = function()
				_Fcitx2Unikey()
			end,
		})
		autocmd({ "CmdlineEnter" }, {
			group = "fcitx",
			pattern = { "[/:\\?]" },
			callback = function()
				_Fcitx2Unikey()
			end,
		})
		autocmd({ "InsertLeave" }, {
			group = "fcitx",
			callback = function()
				_Fcitx2en()
			end,
		})
		autocmd({ "CmdlineLeave" }, {
			group = "fcitx",
			pattern = { "[/:\\?]" },
			callback = function()
				_Fcitx2en()
			end,
		})
	else
		autocmd({ "CmdlineEnter" }, {
			group = "fcitx",
			pattern = { ":" },
			callback = function()
				_Fcitx2en()
			end,
		})
		autocmd({ "InsertLeave" }, {
			group = "fcitx",
			callback = function()
				_Fcitx2en()
			end,
		})
		autocmd({ "CmdlineLeave" }, {
			group = "fcitx",
			pattern = { "[/:\\?]" },
			callback = function()
				_Fcitx2en()
			end,
		})
	end
	--Insert to Unikey
	vim.keymap.set("n", "<A-i>", ":lua _Fcitx2Unikey()<CR>i", { silent = true, noremap = true })
end

local init = {
	start = _FcitxInit(),
}
return init
