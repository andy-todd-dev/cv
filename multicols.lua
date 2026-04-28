-- Converts a fenced div with class "multicols" into a LaTeX multicols environment.
-- Usage in markdown:  ::: {.multicols cols="2"}  ...  :::
function Div(el)
  if el.classes:includes("multicols") then
    local cols = el.attributes["cols"] or "2"
    return {
      pandoc.RawBlock("latex", "\\begin{multicols}{" .. cols .. "}"),
      pandoc.Div(el.content),
      pandoc.RawBlock("latex", "\\end{multicols}"),
    }
  end
end
