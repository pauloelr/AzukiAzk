local lfs   = require('lfs')
local path  = require('azk.utils.path')
local uuid  = require('azk.utils.native.uuid')

local debug    = debug
local type     = type
local error    = error
local tostring = tostring

local utils = {}
setfenv(1, utils)

local current_dir = lfs.currentdir()

function switch(c)
  local swtbl = {
    casevar = c,
    caseof = function (self, code)
      local f
      if (self.casevar) then
        f = code[self.casevar] or code.default
      else
        f = code.missing or code.default
      end
      if f then
        if type(f)=="function" then
          return f(self.casevar,self)
        else
          error("case "..tostring(self.casevar).." not a function")
        end
      end
    end
  }
  return swtbl
end

-- generate unique id
function unique_id(size)
  return uuid.new():lower():gsub("-", ""):sub(0, size or 32)
end

-- File and dir informations
local abs_path = ("@%%.%s(.*)$"):format(path.separator)
function __FILE__(stack)
  local source = debug.getinfo(stack or 2).source
  local source_path = source:match(abs_path)

  if source_path then
    source_path = path.normalize(path.join(current_dir, source_path))
  else
    source_path = source:match("@(.*)$")
  end

  return source_path
end

local basedir = ("^(.*)%s.*$"):format(path.separator)
function __DIR__()
  return __FILE__(3):match(basedir)
end

return utils
