return {
	{
		"pocco81/auto-save.nvim",
		config = function()
			require("auto-save").setup({
				enabled = true,
				execution_message = {
					message = function()
						return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
					end,
					dim = 0.18, -- dim the color of the message
					cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying the message
				},
				trigger_events = { "InsertLeave", "TextChanged" }, -- vim events that trigger auto-save
				conditions = {
					exists = true,
					filename_is_not = {},
					filetype_is_not = {},
					modifiable = true,
				},
				write_all_buffers = false, -- write all buffers when the current one meets conditions
				on_off_commands = true, -- create commands `:AutoSave` to toggle on/off and `:AutoSaveToggle`
				clean_command_line_interval = 0, -- (milliseconds) automatically clean CmdLine after user writes a command
				debounce_delay = 135, -- saves the file at most every debounce_delay milliseconds
			})
		end,
	},
}
