local fs = require "nixio.fs"

local f = SimpleForm("upgrade_info", translate("在线升级结果"))
f.reset = false
f.submit = false

local upgrade_info = fs.readfile("/tmp/adss_upgrade.log") or ""
local t = f:field(TextValue, "upgrade_info")
t.rmempty = true
t.rows = 20
t.readonly = true
t.cfgvalue = function()
    return upgrade_info
end

return f