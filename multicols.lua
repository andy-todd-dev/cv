-- Converts a fenced div with class "multicols" into a LaTeX multicols environment.
-- Usage in markdown:  ::: {.multicols cols="2"}  ...  :::
--
-- Converts a fenced div with class "skilltable" into a compact tabularx table.
-- Each H3 + following paragraph becomes one row.
-- H3s with class {.plain} get plain comma-separated text; others get \cvtag{} pills.
-- Usage in markdown:  ::: {.skilltable}  ...  :::

local function inline_to_text(inlines)
  local result = {}
  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      result[#result + 1] = inline.text
    elseif inline.t == "Space" then
      result[#result + 1] = " "
    elseif inline.t == "Emph" then
      -- recurse into emphasis
      result[#result + 1] = inline_to_text(inline.content)
    elseif inline.t == "SoftBreak" or inline.t == "LineBreak" then
      result[#result + 1] = " "
    end
  end
  return table.concat(result)
end

local function make_tags(para_text)
  -- Split on commas and wrap each item in \cvtag{}
  local tags = {}
  for item in (para_text .. ", "):gmatch("(.-)%s*,%s*") do
    item = item:match("^%s*(.-)%s*$") -- trim
    if item ~= "" then
      tags[#tags + 1] = "\\cvtag{" .. item .. "}"
    end
  end
  return table.concat(tags, " ")
end

local function make_plain(para_text)
  -- Normalize comma-separated plain text
  return para_text:gsub("%s*,%s*", ", ")
end

function Div(el)
  if el.classes:includes("multicols") then
    local cols = el.attributes["cols"] or "2"
    return {
      pandoc.RawBlock("latex", "\\begin{multicols}{" .. cols .. "}"),
      pandoc.Div(el.content),
      pandoc.RawBlock("latex", "\\end{multicols}"),
    }
  end

  if el.classes:includes("summary") then
    return {
      pandoc.RawBlock("latex", "{\\setlength{\\parskip}{0pt}\\linespread{0.95}\\selectfont"),
      pandoc.Div(el.content),
      pandoc.RawBlock("latex", "}"),
    }
  end

  if el.classes:includes("skilltable") then
    local rows = {}
    local current_header = nil
    local header_plain = false

    for _, block in ipairs(el.content) do
      if block.t == "Header" and block.level == 3 then
        current_header = inline_to_text(block.content)
        -- Check if the header has class "plain"
        header_plain = false
        if block.classes then
          for _, cls in ipairs(block.classes) do
            if cls == "plain" then header_plain = true end
          end
        end
      elseif block.t == "Para" and current_header then
        local para_text = inline_to_text(block.content)
        local right_cell
        local spacing = "\\setlength{\\baselineskip}{18pt}\\setlength{\\lineskip}{6pt}"
        if header_plain then
          right_cell = make_plain(para_text)
        else
          right_cell = make_tags(para_text)
        end
        local label = "\\textbf{\\textcolor{headingblue}{" .. current_header:gsub("&", "\\&") .. "}}"
        rows[#rows + 1] = label .. " & " .. right_cell
        current_header = nil
      end
    end

    local tex = {}
    for i, row in ipairs(rows) do
      -- row is "label & right_cell"; split on the first " & "
      local label, right_cell = row:match("^(.-)%s&%s(.+)$")
      tex[#tex + 1] = "\\noindent"
        .. "\\begin{minipage}[c]{2.8cm}\\raggedright " .. label .. "\\end{minipage}%\n"
        .. "\\begin{minipage}[c]{\\dimexpr\\linewidth-2.8cm\\relax}"
        .. "\\setlength{\\baselineskip}{16pt}\\setlength{\\lineskip}{3pt}\\raggedright "
        .. right_cell .. "\\end{minipage}\\par"
      if i < #rows then
        tex[#tex + 1] = "\\vspace{2pt}"
      end
    end

    return pandoc.RawBlock("latex", table.concat(tex, "\n"))
  end
end
