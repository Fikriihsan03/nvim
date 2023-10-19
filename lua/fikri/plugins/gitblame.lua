local gitblame_setup, gitblame = pcall(require, "gitblame")
if not gitblame_setup then
	return
end

gitblame.setup({
	enabled = true,
	message_template = "<sha> • <date> • <author>",
	date_format = "%c",
	message_when_not_committed = "Oh please, commit this !",
})
