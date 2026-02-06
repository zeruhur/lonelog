-- pagebreak.lua
-- Converts horizontal rules (---) to pagebreaks in Typst output

function HorizontalRule(elem)
  if FORMAT:match 'typst' then
    -- Return a Typst pagebreak as raw inline content
    return pandoc.RawBlock('typst', '#pagebreak()')
  end
  -- For other formats, keep the horizontal rule as-is
  return elem
end
