
local M = {}

local describe_it_query = [[
  (call_expression
      function: (identifier) @x (#eq? @x "describe")
      arguments: (
        arguments (string)? @describe-name
        (arrow_function
            body: (statement_block (expression_statement
                  (call_expression
                    function: (identifier) @y (#eq? @y "it")
                    arguments: (arguments (string)? @it-name)
                  ) @it-block
          ))
      ))
  ) @describe-block
]]

-- Captures are indexed in the order they appear in the query
-- 1 - @x
-- 2 - @describe-name
-- 3 - @y
-- 4 - @it-name
-- 5 - @it-block
-- 6 - @describe-block
--
local function get_parser_language()
  local bnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bnr, "filetype")
  return require("nvim-treesitter.parsers").ft_to_lang(ft)
end

function M.get_tests()
  local bnr = vim.api.nvim_get_current_buf()
  local parser_language = get_parser_language()
  local q = require("vim.treesitter.query")
  local language_tree = vim.treesitter.get_parser(bnr, parser_language)
  local syntax_tree = language_tree:parse()

  local root = syntax_tree[1]:root()

  local result = {}
  local query = vim.treesitter.parse_query(parser_language, describe_it_query)

  for _, captures, _ in query:iter_matches(root, bnr) do
    local test_table = {
      describe_start = captures[6]:start(),
      describe_end = captures[6]:end_(),
      describes = {q.get_node_text(captures[2], bnr)},
      it = q.get_node_text(captures[4], bnr),
      it_start = captures[5]:start(),
      it_end = captures[5]:end_()
    }

    local last_desc
    for _, existing_block in ipairs(result) do
      if(existing_block.describe_start < test_table.describe_start and existing_block.describe_end > test_table.describe_end) then
        local parent_describes = existing_block.describes
        for _, desc in ipairs(parent_describes) do
          if last_desc ~= desc then
            last_desc = desc
            table.insert(test_table.describes, desc)
          end
        end
      end
    end

    local descs = test_table.describes
    local desc_string = ""
    for j=#descs,1, -1 do
      local part = test_table.describes[j]
      desc_string = desc_string .. ' ' .. string.sub(part, 2, #part - 1)
    end
    local it_string = test_table.it
    local test_string = desc_string .. ' ' .. string.sub(it_string, 2, #it_string - 1)
    test_table["test_string"] = string.sub(test_string, 2, #test_string)

    table.insert(result, test_table)
  end

  return result;
end

function M.find_test_string()
  local tests = M.get_tests()
  if (#tests == 0) then
    return "no-tests"
  end

  local line_num = vim.api.nvim_win_get_cursor(0)[1]

  for _, test in ipairs(tests) do
    if test.it_start <= line_num and test.it_end >= line_num then
      return test.test_string
    end
  end

  return ""
end

function M.get_output_string()
  local test_string = M.find_test_string()
  if (test_string == "no-tests") then
    return "no-tests"
  end

  local file = vim.fn.expand('%:p')

  return "yarn --cwd=assets test " .. file .. " -t \"" .. test_string .. "\""
end

function M.run_jest_test()
  local parser_language = get_parser_language()

  if not (parser_language == "tsx" or parser_language == "javascript") then
    print("Not a jest language")
    return
  end

  local yarn_string = M.get_output_string()
  if (yarn_string == "no-tests") then
    print("No jest tests")
  else
    vim.api.nvim_command(':Tmux ' .. yarn_string)
  end
end

return M
