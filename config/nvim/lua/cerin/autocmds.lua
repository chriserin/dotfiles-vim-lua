local augroup = require('core.utils').augroup

-- automatic spell check for some file types
augroup('KeywordProgram', {
  {
    event = { 'FileType' },
    pattern = { 'lua' },
    command = 'setlocal keywordprg=:help',
  },
})

augroup('NeoAI', {
  {
    event = { 'FileType' },
    pattern = { 'neoai-input' },
    command = function()
      vim.api.nvim_buf_set_keymap(
        0,
        'n',
        '<leader>ns',
        '<cmd>lua require("neoai.ui").submit_prompt()<CR>',
        { desc = 'Submit the neoai input' }
      )
    end,
  },
  {
    event = { 'FileType' },
    pattern = { 'neoai-output' },
    command = 'set ft=markdown',
  },
})
