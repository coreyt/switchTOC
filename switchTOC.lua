--[[
switchTOC – Switch from Azure Wiki TOC format to docx.
Copyright © 2023 Corey Thompson
MIT License
]]

--[[
This is a JSON representation of the part of the Pandoc AST that we wanted to catch.  A little tricky because the underline character == Emphasis in markdown.
{
"t": "Para",
"c": [
    {
        "t": "Str",
        "c": "[["
    },
    {
        "t": "Emph",
        "c": [
            {
                "t": "Str",
                "c": "TOC"
            }
        ]
    },
    {
        "t": "Str",
        "c": "[["  <-- this is backwards
    }
]
},
]]

local stringify_orig = (require 'pandoc.utils').stringify

local function stringify(x)
  return type(x) == 'string' and x or stringify_orig(x)
end

--- configs – these are populated in the Meta filter.
local toc = {
  ooxml = [[
<w:sdt>
  <w:sdtContent>
      <w:p>
          <w:r>
              <w:fldChar w:fldCharType="begin" w:dirty="true" />
              <w:instrText xml:space="preserve">TOC \o "1-2" \h \z \u</w:instrText>
              <w:fldChar w:fldCharType="separate" />
              <w:fldChar w:fldCharType="end" />
          </w:r>
      </w:p>
  </w:sdtContent>
</w:sdt>
]]
}

--- Return a block element that is appropriate for the given output format (we could make this work for different types of output.)
local function newtoc(format)
  if format == 'docx' then
    return pandoc.RawBlock('openxml', toc.ooxml)
  else
    -- fall back to nothing
    return nil
  end
end


-- [trace] Parsed [Para [Str "[[",Emph [Str "TOC"],Str "]]"]]
function Para(elem)
    if elem.content[1] and elem.content[1].text == '[[' and 
    elem.content[2] and elem.content[2].tag == 'Emph' and 
    elem.content[3] and elem.content[3].text == ']]' then
        if elem.content[2].content[1].text =="TOC" then
            return pandoc.RawBlock('openxml',toc.ooxml)
        end
    end
end

return {{ Para = Para }}
