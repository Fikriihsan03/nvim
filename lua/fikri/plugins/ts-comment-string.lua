local status, ts_comment_string = pcall(require, "ts_context_commentstring")
if not status then
	return
end

ts_comment_string.setup({
	enable_autocmd = false,
})
