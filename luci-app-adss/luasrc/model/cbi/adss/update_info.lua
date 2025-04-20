local fs = require "nixio.fs"

local f = SimpleForm("update_info", translate("检查更新结果"))
f.reset = false
f.submit = false

local update_info = fs.readfile("/tmp/adss_check_update.log") or ""
local t = f:field(TextValue, "update_info")
t.rmempty = true
t.rows = 20
t.readonly = true
t.cfgvalue = function()
    return update_info
end

return f