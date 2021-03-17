local counter = 1

local config = {
	_default = "print('%d')",
	lua = "print('%d')",
	python = "print('%d')",
	rust = "println!('%d')",
}

local M = {}
function M.setup(cfg)
	config = vim.tbl_extend('force', config, cfg)
end
--- Creates a function to insert customized numbered print statements.
---
--@param context (string, default "print('%d')") The format string for the debug
--- statement. Should contain a single `%d`, which will be the insertion point
--- of the current counter value.
function M.debug_statement_factory(context)
	local context = config[context] or config._default

	--- Adds numbered print statements.
	---
	--- Calling the function inserts a print statement at the current cursor
	--- position with the current counter - value and increments the counter.
	--- The counter starts at 1.
	---
	--- If the function is called with a {count}, the counter is set to {count}, a
	--- print statement with {count} is inserted, and the counter is incremented.
	---
	--@param count (number, default: current counter value)
	return function(count)
		local count = count ~= 0 and count or counter
		local pos = vim.api.nvim_win_get_cursor(0)
		local row = pos[1] - 1 -- make 0-idx'd
		local col = pos[2]  -- already 0-idx'd
		local line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
		local _, last = line:find("^%s*")
		local ws = line:sub(1, last)
		vim.api.nvim_buf_set_text(0, row, last, row, last, {string.format(context, count), ws})
		vim.api.nvim_win_set_cursor(0, {row + 2, col})
		counter = count + 1
	end
end

-- Default for current filetype
M.add_statement = M.debug_statement_factory(vim.bo.filetype)

return M
