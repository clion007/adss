local m, s, o
local fs = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local version = "4.2"

m = Map("adss", translate("ADSS广告过滤"), 
    translate("基于dnsmasq的广告过滤系统") .. 
    "<br/><br/>" .. translate("当前版本") .. ": <b>" .. version .. "</b>")

s = m:section(TypedSection, "basic", translate("基本设置"))
s.anonymous = true

o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

o = s:option(Value, "update_time", translate("更新时间(小时)"))
o.datatype = "range(0,23)"
o.default = "4"
o.rmempty = false

o = s:option(Value, "update_minute", translate("更新时间(分钟)"))
o.datatype = "range(0,59)"
o.default = "0"
o.rmempty = false

o = s:option(Value, "keep_log_days", translate("日志保留天数"))
o.datatype = "range(1,30)"
o.default = "7"

o = s:option(Button, "_check_update", translate("检查更新"))
o.inputtitle = translate("检查")
o.inputstyle = "apply"
o.write = function()
    luci.sys.call("/usr/share/adss/check_update.sh >/tmp/adss_check_update.log 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "adss", "update_info"))
end

o = s:option(Button, "_update", translate("立即更新规则"))
o.inputtitle = translate("更新")
o.inputstyle = "reload"
o.write = function()
    luci.sys.call("/usr/share/adss/rules_update.sh >/dev/null 2>&1 &")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "adss", "status"))
end

return m