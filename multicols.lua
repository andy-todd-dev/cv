-- Converts a fenced div with class "multicols" into a LaTeX multicols environment.
-- Usage in markdown:  ::: {.multicols cols="2"}  ...  :::
--
-- Converts a fenced div with class "skilltable" into a compact tabularx table.
-- Each H3 + following paragraph becomes one row.
-- H3s with class {.plain} get plain comma-separated text; others get \cvtag{} pills.
-- Usage in markdown:  ::: {.skilltable}  ...  :::

local extracted_contact = {}

local function trim(value)
  return (value or ""):match("^%s*(.-)%s*$")
end

local function normalize_url_label(url)
  local label = trim(url)
  if label == "" then
    return ""
  end
  label = label:gsub("^%a+://", "")
  label = label:gsub("^www%.", "")
  label = label:gsub("[?#].*$", "")
  label = label:gsub("/$", "")
  return label
end

local function meta_to_text(value)
  if not value then
    return ""
  end
  return trim(pandoc.utils.stringify(value))
end

local function parse_contact_line(line)
  local key, value = line:match("^%s*([^:]+):%s*(.-)%s*$")
  if not key or not value or value == "" then
    return
  end

  local normalized_key = key:lower():gsub("[^a-z]", "")
  local mapped_keys = {
    name = "name",
    location = "location",
    phone = "phone",
    email = "email",
    linkedin = "linkedin",
    github = "github",
  }

  local target_key = mapped_keys[normalized_key]
  if target_key then
    extracted_contact[target_key] = trim(value)
  end
end

local function parse_contact_block(content)
  for _, block in ipairs(content) do
    if block.t == "Para" or block.t == "Plain" then
      parse_contact_line(pandoc.utils.stringify(block))
    elseif block.t == "BulletList" then
      for _, item in ipairs(block.content) do
        for _, item_block in ipairs(item) do
          if item_block.t == "Para" or item_block.t == "Plain" then
            parse_contact_line(pandoc.utils.stringify(item_block))
          end
        end
      end
    end
  end
end

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
  if el.classes:includes("contact") then
    parse_contact_block(el.content)
    -- Keep contact data visible in markdown source but omit duplicated body output in PDF.
    return {}
  end

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

function Pandoc(doc)
  for key, value in pairs(extracted_contact) do
    if value ~= "" then
      doc.meta[key] = pandoc.MetaString(value)
    end
  end

  local linkedin_url = meta_to_text(doc.meta.linkedin)
  local github_url = meta_to_text(doc.meta.github)

  if linkedin_url ~= "" then
    doc.meta.linkedin_label = pandoc.MetaString(normalize_url_label(linkedin_url))
  end
  if github_url ~= "" then
    doc.meta.github_label = pandoc.MetaString(normalize_url_label(github_url))
  end

  return doc
end
