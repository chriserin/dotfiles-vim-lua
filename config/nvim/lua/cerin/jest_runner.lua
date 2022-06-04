
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

local function get_tests()
  local bnr = vim.api.nvim_get_current_buf()
  local q = require("vim.treesitter.query")
  local language_tree = vim.treesitter.get_parser(bnr, 'javascript')
  local syntax_tree = language_tree:parse()

  local root = syntax_tree[1]:root()

  local result = {}
  local query = vim.treesitter.parse_query('javascript', describe_it_query)

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

local function find_test_string()
  local tests = get_tests()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]

  for _, test in ipairs(tests) do
    if test.it_start <= line_num and test.it_end >= line_num then
      return test.test_string
    end
  end
end

local function get_output_string()
  local test_string = find_test_string()
  local file = vim.fn.expand('%:p')

  return "yarn test " .. file .. " -t \"" .. test_string .. "\""
end

function RunJestTest()
  local yarn_string = get_output_string()
  vim.api.nvim_command(':Tmux ' .. yarn_string)
end

vim.keymap.set('n', '<leader>j', ":lua RunJestTest()<cr>")
