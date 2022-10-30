local augroup = require('core.utils').augroup

-- automatic spell check for some file types
augroup('KeywordProgram', {
  {
    event = { 'FileType' },
    pattern = { 'lua' },
    command = 'setlocal keywordprg=:help',
  },
})
