--[[
switchTOC – Switch from Azure Wiki TOC format to docx.
Copyright © 2023 Corey Thompson
MIT License
]]
local stringify_orig = (require 'pandoc.utils').stringify

local function stringify(x)
  return type(x) == 'string' and x or stringify_orig(x)
end

--- configs – these are populated in the Meta filter.
local toc = {
  ooxml = [[
    <w:sdt><w:sdtPr><w:docPartObj>
    <w:docPartGallery w:val="Table of Contents" /><w:docPartUnique />
    </w:docPartObj></w:sdtPr><w:sdtContent><w:p><w:pPr>
    <w:pStyle w:val="TOCHeading" /></w:pPr><w:r>
    <w:t>Table of Contents</w:t></w:r></w:p><w:p><w:r>
    <w:fldChar w:fldCharType="begin" w:dirty="true" />
    <w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u 
    </w:instrText><w:fldChar w:fldCharType="separate" />
    <w:fldChar w:fldCharType="end" /></w:r></w:p></w:sdtContent></w:sdt>
  ]]
}

--- Return a block element causing a page break in the given format.
local function newtoc(format)
  if format == 'docx' then
    return pandoc.RawBlock('openxml', toc.ooxml)
  else
    -- fall back to nothing
    return nil
  end
end

-- check that the block only contains '[[_TOC_]]'
local function found_newtoc_command(command)
  return command:match '^\[\[_TOC_\]\]%{?%}?$'
end

-- Filter function called on each RawBlock element.
function RawBlock (el)
  -- check that the block is markdown.
  if el.format:match 'markdown' and found_newtoc_command(el.text) then
    -- use format-specific (docx) TOC code. FORMAT is set by pandoc to
    -- the targeted output format.
    return newtoc(FORMAT)
  end
  -- otherwise, leave the block unchanged
  return nil
end
  
  return {
    {RawBlock = RawBlock, Para = Para}
  }
