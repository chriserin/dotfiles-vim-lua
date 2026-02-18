local M = {}

-- Helpers ----------------------------------------------------------------

local function get_node_text(node, source)
  local sr, sc, er, ec = node:range()
  if sr == er then
    return source[sr + 1] and source[sr + 1]:sub(sc + 1, ec) or ""
  end
  local lines = {}
  for i = sr, er do
    local line = source[i + 1] or ""
    if i == sr then
      lines[#lines + 1] = line:sub(sc + 1)
    elseif i == er then
      lines[#lines + 1] = line:sub(1, ec)
    else
      lines[#lines + 1] = line
    end
  end
  return table.concat(lines, "\n")
end

local function indent(level)
  return string.rep(" ", level)
end

local function format_comment(node, source, indent_level)
  local text = get_node_text(node, source):match("^%s*(.-)%s*$")
  return indent(indent_level) .. text
end

-- Emit raw source lines for a node, re-indented to indent_level.
-- Used as a fallback when a node has parse errors.
local function raw_node_lines(node, source, indent_level)
  local out = {}
  local sr, _, er, _ = node:range()
  local raw = {}
  for i = sr, er do
    raw[#raw + 1] = source[i + 1] or ""
  end
  local min_indent = math.huge
  for _, line in ipairs(raw) do
    if line:match("%S") then
      local leading = #(line:match("^(%s*)") or "")
      if leading < min_indent then min_indent = leading end
    end
  end
  if min_indent == math.huge then min_indent = 0 end
  for _, line in ipairs(raw) do
    if not line:match("%S") then
      out[#out + 1] = ""
    else
      out[#out + 1] = indent(indent_level) .. line:sub(min_indent + 1)
    end
  end
  return out
end

-- Step keyword alignment -------------------------------------------------

local step_keywords = { "Given ", "When ", "Then ", "And ", "But ", "* " }

local function max_keyword_width()
  local w = 0
  for _, kw in ipairs(step_keywords) do
    if #kw > w then w = #kw end
  end
  return w
end

local KW_WIDTH = max_keyword_width() -- 6 for English

local function pad_keyword(kw_text)
  -- kw_text comes from the parser and includes trailing space
  -- Trim then re-pad to KW_WIDTH
  local trimmed = kw_text:match("^(.-)%s*$")
  return trimmed .. string.rep(" ", KW_WIDTH - #trimmed)
end

-- Table alignment --------------------------------------------------------

local function format_table_rows(table_node, source, indent_level)
  local out = {}
  local rows_data = {} -- { { cell1, cell2, ... }, ... }
  local col_widths = {}

  -- First pass: collect cell text and compute column widths
  for child in table_node:iter_children() do
    local ctype = child:type()
    if ctype == "table_row" or ctype == "table_head_row" then
      local cells = {}
      for col in child:iter_children() do
        if col:type() == "table_col" then
          local cell_node = col:named_child(0)
          local text = ""
          if cell_node and cell_node:type() == "table_cell" then
            text = get_node_text(cell_node, source):match("^%s*(.-)%s*$") or ""
          end
          cells[#cells + 1] = text
        end
      end
      rows_data[#rows_data + 1] = cells
      for i, cell in ipairs(cells) do
        col_widths[i] = math.max(col_widths[i] or 0, #cell)
      end
    end
  end

  -- Second pass: emit padded rows
  for _, cells in ipairs(rows_data) do
    local parts = {}
    for i, cell in ipairs(cells) do
      local w = col_widths[i] or #cell
      parts[#parts + 1] = " " .. cell .. string.rep(" ", w - #cell) .. " "
    end
    out[#out + 1] = indent(indent_level) .. "|" .. table.concat(parts, "|") .. "|"
  end

  return out
end

-- Doc string formatting --------------------------------------------------

local function format_doc_string(ds_node, source, indent_level)
  local out = {}
  local delimiter = nil
  local media = nil
  local content_lines = {}

  for child in ds_node:iter_children() do
    local ctype = child:type()
    if ctype == "media_type" then
      media = get_node_text(child, source)
    elseif ctype == "doc_string_content" then
      local sr, _, er, _ = child:range()
      for i = sr, er do
        content_lines[#content_lines + 1] = source[i + 1] or ""
      end
    end
  end

  -- Detect delimiter from source text
  local ds_sr = ds_node:start()
  local first_line = source[ds_sr + 1] or ""
  if first_line:find('"""') then
    delimiter = '"""'
  else
    delimiter = "```"
  end

  -- Opening delimiter
  local open = indent(indent_level) .. delimiter
  if media then
    open = open .. media
  end
  out[#out + 1] = open

  -- Detect original indentation from content to preserve relative indent
  local min_indent = math.huge
  for _, line in ipairs(content_lines) do
    if line:match("%S") then
      local leading = #(line:match("^(%s*)") or "")
      if leading < min_indent then min_indent = leading end
    end
  end
  if min_indent == math.huge then min_indent = 0 end

  for _, line in ipairs(content_lines) do
    if not line:match("%S") then
      out[#out + 1] = ""
    else
      local stripped = line:sub(min_indent + 1)
      out[#out + 1] = indent(indent_level) .. stripped
    end
  end

  -- Closing delimiter
  out[#out + 1] = indent(indent_level) .. delimiter

  return out
end

-- Description formatting -------------------------------------------------

local function format_description(desc_node, source, indent_level)
  local out = {}
  local sr, _, er, _ = desc_node:range()
  local raw_lines = {}
  for i = sr, er do
    raw_lines[#raw_lines + 1] = source[i + 1] or ""
  end

  -- Find minimum indentation to preserve relative indent
  local min_indent = math.huge
  for _, line in ipairs(raw_lines) do
    if line:match("%S") then
      local leading = #(line:match("^(%s*)") or "")
      if leading < min_indent then min_indent = leading end
    end
  end
  if min_indent == math.huge then min_indent = 0 end

  for _, line in ipairs(raw_lines) do
    if not line:match("%S") then
      out[#out + 1] = ""
    else
      local stripped = line:sub(min_indent + 1)
      out[#out + 1] = indent(indent_level) .. stripped
    end
  end

  return out
end

-- Step formatting --------------------------------------------------------

local function format_step(step_node, source, indent_level)
  local out = {}
  -- step_node is given_step, when_step, then_step, and_step, but_step, asterisk_step
  for child in step_node:iter_children() do
    local ctype = child:type()
    if ctype:match("_line$") then
      -- This is given_line, when_line, etc.
      local kw_text = ""
      local ctx_text = ""
      for lc in child:iter_children() do
        local ltype = lc:type()
        if ltype:match("_kw$") or ltype == "* " then
          kw_text = get_node_text(lc, source)
        elseif ltype == "step_context" then
          ctx_text = get_node_text(lc, source)
        end
      end
      if kw_text == "" then
        -- asterisk step: keyword is literal "* "
        kw_text = "* "
      end
      out[#out + 1] = indent(indent_level) .. pad_keyword(kw_text) .. ctx_text
    elseif ctype == "step_arg" then
      for arg_child in child:iter_children() do
        local atype = arg_child:type()
        if atype == "data_table" then
          local rows = format_table_rows(arg_child, source, indent_level + 2)
          for _, row in ipairs(rows) do
            out[#out + 1] = row
          end
        elseif atype == "doc_string" then
          local ds = format_doc_string(arg_child, source, indent_level + 2)
          for _, line in ipairs(ds) do
            out[#out + 1] = line
          end
        end
      end
    elseif ctype == "step_body" then
      local body = raw_node_lines(child, source, indent_level + 2)
      for _, line in ipairs(body) do
        out[#out + 1] = line
      end
    end
  end
  return out
end

-- Helper to check if a node type is a step group or individual step.
-- Both `steps` and `_alt_steps` are inlined in the grammar, so groups
-- (given_group, when_group, then_group) and individual alt-steps
-- (and_step, but_step, asterisk_step) appear as direct children of
-- scenario / background nodes rather than inside a `steps` wrapper.

local function is_step_group(ntype)
  return ntype == "given_group" or ntype == "when_group" or ntype == "then_group"
end

local function is_step_node(ntype)
  return ntype == "given_step" or ntype == "when_step" or ntype == "then_step"
      or ntype == "and_step" or ntype == "but_step" or ntype == "asterisk_step"
end


-- Tag formatting ---------------------------------------------------------

local function format_tags(tags_node, source, indent_level)
  local parts = {}
  for child in tags_node:iter_children() do
    if child:type() == "tag" then
      parts[#parts + 1] = get_node_text(child, source)
    end
  end
  if #parts > 0 then
    return indent(indent_level) .. table.concat(parts, " ")
  end
  return nil
end

-- Examples formatting ----------------------------------------------------

local function format_examples_def(exdef_node, source, indent_level)
  local out = {}
  for child in exdef_node:iter_children() do
    local ctype = child:type()
    if ctype == "tags" then
      local tag_line = format_tags(child, source, indent_level)
      if tag_line then out[#out + 1] = tag_line end
    elseif ctype == "examples" then
      for ec in child:iter_children() do
        local etype = ec:type()
        if etype == "examples_line" then
          local kw = ""
          local ctx = ""
          for lc in ec:iter_children() do
            if lc:type() == "examples_kw" then
              kw = get_node_text(lc, source)
            elseif lc:type() == "context" then
              ctx = " " .. get_node_text(lc, source)
            end
          end
          out[#out + 1] = indent(indent_level) .. kw .. ":" .. ctx
        elseif etype == "description_helper" then
          for dc in ec:iter_children() do
            if dc:type() == "description" then
              local desc = format_description(dc, source, indent_level + 2)
              for _, l in ipairs(desc) do out[#out + 1] = l end
            end
          end
        elseif etype == "examples_table" then
          local rows = format_table_rows(ec, source, indent_level + 2)
          for _, row in ipairs(rows) do
            out[#out + 1] = row
          end
        end
      end
    end
  end
  return out
end

-- Scenario formatting ----------------------------------------------------

local function format_scenario_def(scdef_node, source, indent_level)
  -- If the whole scenario_definition has errors, preserve raw
  if scdef_node:has_error() then
    return raw_node_lines(scdef_node, source, indent_level)
  end
  local out = {}
  for child in scdef_node:iter_children() do
    local ctype = child:type()
    if ctype == "tags" then
      local tag_line = format_tags(child, source, indent_level)
      if tag_line then out[#out + 1] = tag_line end
    elseif ctype == "scenario" then
      for sc in child:iter_children() do
        local stype = sc:type()
        if stype == "scenario_line" or stype == "scenario_outline_line" then
          local kw = ""
          local ctx = ""
          for lc in sc:iter_children() do
            local ltype = lc:type()
            if ltype == "scenario_kw" or ltype == "scenario_outline_kw" then
              kw = get_node_text(lc, source)
            elseif ltype == "context" then
              ctx = " " .. get_node_text(lc, source)
            end
          end
          out[#out + 1] = indent(indent_level) .. kw .. ":" .. ctx
        elseif stype == "description_helper" then
          for dc in sc:iter_children() do
            if dc:type() == "description" then
              local desc = format_description(dc, source, indent_level + 2)
              for _, l in ipairs(desc) do out[#out + 1] = l end
            end
          end
        elseif is_step_group(stype) then
          for step in sc:iter_children() do
            if is_step_node(step:type()) then
              local lines = format_step(step, source, indent_level + 2)
              for _, l in ipairs(lines) do out[#out + 1] = l end
            end
          end
        elseif is_step_node(stype) then
          local lines = format_step(sc, source, indent_level + 2)
          for _, l in ipairs(lines) do out[#out + 1] = l end
        elseif stype == "examples_definition" then
          out[#out + 1] = ""
          local ex = format_examples_def(sc, source, indent_level + 2)
          for _, l in ipairs(ex) do out[#out + 1] = l end
        end
      end
    end
  end
  return out
end

-- Background formatting --------------------------------------------------

local function format_background(bg_node, source, indent_level)
  if bg_node:has_error() then
    return raw_node_lines(bg_node, source, indent_level)
  end
  local out = {}
  for child in bg_node:iter_children() do
    local ctype = child:type()
    if ctype == "background_line" then
      local kw = ""
      local ctx = ""
      for lc in child:iter_children() do
        if lc:type() == "background_kw" then
          kw = get_node_text(lc, source)
        elseif lc:type() == "context" then
          ctx = " " .. get_node_text(lc, source)
        end
      end
      out[#out + 1] = indent(indent_level) .. kw .. ":" .. ctx
    elseif ctype == "description_helper" then
      for dc in child:iter_children() do
        if dc:type() == "description" then
          local desc = format_description(dc, source, indent_level + 2)
          for _, l in ipairs(desc) do out[#out + 1] = l end
        end
      end
    elseif is_step_group(ctype) then
      for step in child:iter_children() do
        if is_step_node(step:type()) then
          local lines = format_step(step, source, indent_level + 2)
          for _, l in ipairs(lines) do out[#out + 1] = l end
        end
      end
    elseif is_step_node(ctype) then
      local lines = format_step(child, source, indent_level + 2)
      for _, l in ipairs(lines) do out[#out + 1] = l end
    end
  end
  return out
end

-- Rule formatting --------------------------------------------------------

local function format_rule(rule_node, source, indent_level)
  local out = {}
  local past_header = false
  for child in rule_node:iter_children() do
    local ctype = child:type()
    if ctype == "rule_header" then
      for hc in child:iter_children() do
        local htype = hc:type()
        if htype == "tags" then
          local tag_line = format_tags(hc, source, indent_level)
          if tag_line then out[#out + 1] = tag_line end
        elseif htype == "rule_line" then
          local kw = ""
          local ctx = ""
          for lc in hc:iter_children() do
            if lc:type() == "rule_kw" then
              kw = get_node_text(lc, source)
            elseif lc:type() == "context" then
              ctx = " " .. get_node_text(lc, source)
            end
          end
          out[#out + 1] = indent(indent_level) .. kw .. ":" .. ctx
        elseif htype == "description_helper" then
          for dc in hc:iter_children() do
            if dc:type() == "description" then
              local desc = format_description(dc, source, indent_level + 2)
              for _, l in ipairs(desc) do out[#out + 1] = l end
            end
          end
        end
      end
      past_header = true
    elseif ctype == "comment" then
      out[#out + 1] = ""
      out[#out + 1] = format_comment(child, source, indent_level + 2)
    elseif ctype == "background" then
      if past_header then out[#out + 1] = "" end
      local bg = format_background(child, source, indent_level + 2)
      for _, l in ipairs(bg) do out[#out + 1] = l end
    elseif ctype == "scenario_definition" then
      out[#out + 1] = ""
      local sc = format_scenario_def(child, source, indent_level + 2)
      for _, l in ipairs(sc) do out[#out + 1] = l end
    elseif child:named() then
      out[#out + 1] = ""
      local raw = raw_node_lines(child, source, indent_level + 2)
      for _, l in ipairs(raw) do out[#out + 1] = l end
    end
  end
  return out
end

-- Feature formatting -----------------------------------------------------

local function format_feature(feature_node, source)
  local out = {}

  for child in feature_node:iter_children() do
    local ctype = child:type()
    if ctype == "feature_header" then
      for hc in child:iter_children() do
        local htype = hc:type()
        if htype == "language" then
          out[#out + 1] = get_node_text(hc, source)
        elseif htype == "tags" then
          local tag_line = format_tags(hc, source, 0)
          if tag_line then out[#out + 1] = tag_line end
        elseif htype == "feature_line" then
          local kw = ""
          local ctx = ""
          for lc in hc:iter_children() do
            if lc:type() == "feature_kw" then
              kw = get_node_text(lc, source)
            elseif lc:type() == "context" then
              ctx = " " .. get_node_text(lc, source)
            end
          end
          out[#out + 1] = kw .. ":" .. ctx
        elseif htype == "description_helper" then
          for dc in hc:iter_children() do
            if dc:type() == "description" then
              local desc = format_description(dc, source, 2)
              for _, l in ipairs(desc) do out[#out + 1] = l end
            end
          end
        end
      end
    elseif ctype == "comment" then
      out[#out + 1] = ""
      out[#out + 1] = format_comment(child, source, 2)
    elseif ctype == "background" then
      out[#out + 1] = ""
      local bg = format_background(child, source, 2)
      for _, l in ipairs(bg) do out[#out + 1] = l end
    elseif ctype == "scenario_definition" then
      out[#out + 1] = ""
      local sc = format_scenario_def(child, source, 2)
      for _, l in ipairs(sc) do out[#out + 1] = l end
    elseif ctype == "rule" then
      out[#out + 1] = ""
      local rule = format_rule(child, source, 2)
      for _, l in ipairs(rule) do out[#out + 1] = l end
    elseif child:named() then
      -- Fallback for ERROR nodes or unexpected named children
      out[#out + 1] = ""
      local raw = raw_node_lines(child, source, 2)
      for _, l in ipairs(raw) do out[#out + 1] = l end
    end
  end

  return out
end

-- Public API -------------------------------------------------------------

function M.format(bufnr, lines)
  -- Parse the lines as a string with a throwaway parser to avoid disturbing
  -- the buffer's language tree (which would trigger fold-update crashes).
  local src = table.concat(lines, "\n")
  local ok, parser = pcall(vim.treesitter.get_string_parser, src, "gherkin")
  if not ok or not parser then
    return nil, "no gherkin parser available"
  end

  local trees = parser:parse()
  if not trees or #trees == 0 then
    return lines, nil
  end

  local tree = trees[1]
  local root = tree:root()

  -- Safety: only bail if there is no feature node at all (total parse failure).
  -- Localized errors within scenarios are handled by falling back to raw
  -- source text for those individual nodes.
  local has_feature = false
  for child in root:iter_children() do
    if child:type() == "feature" then
      has_feature = true
      break
    end
  end
  if not has_feature then
    return lines, nil
  end

  local out = {}
  local source = lines

  for child in root:iter_children() do
    local ctype = child:type()
    if ctype == "comment" then
      out[#out + 1] = get_node_text(child, source):match("^%s*(.-)%s*$")
    elseif ctype == "feature" then
      -- Collect any comments between root-level nodes handled above
      local feature_out = format_feature(child, source)
      for _, l in ipairs(feature_out) do
        out[#out + 1] = l
      end
    end
  end

  -- Ensure file ends with a single newline (add empty string so join+"\n" works)
  -- Strip trailing blank lines
  while #out > 0 and out[#out] == "" do
    table.remove(out)
  end
  out[#out + 1] = ""

  return out, nil
end

return M
