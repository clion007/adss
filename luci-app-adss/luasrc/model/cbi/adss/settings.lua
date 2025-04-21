local m, s, o
local fs = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local http = require "luci.http"
local dispatcher = require "luci.dispatcher"
local i18n = require "luci.i18n"
-- 导入CBI模块
local cbi = require "luci.cbi"
local Map = Map
local Section = Section
local TypedSection = TypedSection
local Flag = Flag
local Value = Value
local Button = Button
local DynamicList = DynamicList
local ListValue = ListValue

-- 定义translate函数的简写
local function translate(...)
    return i18n.translate(...)
end

-- 从version.sh获取版本号
local version_info = ""
if fs.access("/usr/share/adss/version.sh") then
    version_info = sys.exec("/usr/share/adss/version.sh")
end

local adss_version = version_info:match("版本: ([^\n]+)")
if not adss_version then
    adss_version = "4.2" -- 默认版本
end

local m = Map("adss", translate("ADSS广告过滤"), 
    translate("基于dnsmasq的广告过滤系统") .. 
    "<br/><br/>" .. translate("当前版本") .. ": <b style='color:#0099CC'>" .. adss_version .. "</b>")

-- 添加CSS样式美化界面
m.css = [[
<style>
.cbi-button-apply {
    background-color: #0099CC !important;
    color: white !important;
    border: none !important;
    border-radius: 4px !important;
    padding: 6px 15px !important;
}
.cbi-button-reload {
    background-color: #5CB85C !important;
    color: white !important;
    border: none !important;
    border-radius: 4px !important;
    padding: 6px 15px !important;
}
.cbi-section {
    background-color: #f9f9f9 !important;
    border-radius: 5px !important;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1) !important;
    padding: 15px !important;
    margin-bottom: 20px !important;
}
.cbi-value-title {
    font-weight: bold !important;
}
</style>
]]

-- 基本设置部分
local s = m:section(TypedSection, "basic", translate("基本设置"))
s.anonymous = true

local o = s:option(Flag, "enabled", translate("启用"))
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
o.description = translate("超过设定天数的日志将被自动清理")

o = s:option(Value, "net_check_interval", translate("网络检测间隔(分钟)"))
o.datatype = "range(1,60)"
o.default = "5"

o = s:option(ListValue, "rules_priority", translate("规则优先级"))
o:value("1", translate("最高 (优先于其他DNS插件)"))
o:value("0", translate("普通"))
o.default = "1"
o.description = translate("设置ADSS规则相对于其他DNS插件(如Passwall)的优先级")

-- 自定义规则源部分
local s2 = m:section(TypedSection, "rule_source", translate("自定义规则源"))
s2.anonymous = true
s2.addremove = true
s2.template = "cbi/tblsection"

local name = s2:option(Value, "name", translate("名称"))
name.rmempty = false

local url = s2:option(Value, "url", translate("URL"))
url.rmempty = false
url.description = translate("支持http/https链接，指向hosts或dnsmasq格式的规则文件")

local type = s2:option(ListValue, "type", translate("类型"))
type:value("hosts", translate("Hosts规则"))
type:value("dnsmasq", translate("Dnsmasq规则"))
type.default = "dnsmasq"

local enabled = s2:option(Flag, "enabled", translate("启用"))
enabled.default = "1"
enabled.rmempty = false

-- 白名单和黑名单部分
local s3 = m:section(TypedSection, "custom", translate("自定义规则"))
s3.anonymous = true

local whitelist = s3:option(DynamicList, "whitelist", translate("白名单"))
whitelist.description = translate("添加到白名单的域名将不会被过滤")
whitelist.rmempty = true

local blacklist = s3:option(DynamicList, "blacklist", translate("黑名单"))
blacklist.description = translate("添加到黑名单的域名将被强制过滤")
blacklist.rmempty = true

-- 操作按钮部分
local s4 = m:section(TypedSection, "basic", translate("操作"))
s4.anonymous = true

local o = s4:option(Button, "_check_update", translate("检查更新"))
o.inputtitle = translate("检查")
o.inputstyle = "apply"
o.write = function()
    sys.call("/usr/share/adss/check_update.sh >/tmp/adss_check_update.log 2>&1")
    http.redirect(dispatcher.build_url("admin", "services", "adss", "update_info"))
end

o = s4:option(Button, "_update", translate("立即更新规则"))
o.inputtitle = translate("更新")
o.inputstyle = "reload"
o.write = function()
    sys.call("/usr/share/adss/rules_update.sh >/tmp/adss_update.log 2>&1 &")
    http.redirect(dispatcher.build_url("admin", "services", "adss", "status"))
end

o = s4:option(Button, "_online_upgrade", translate("在线升级"))
o.inputtitle = translate("升级")
o.inputstyle = "apply"
o.write = function()
    sys.call("/usr/share/adss/online_upgrade.sh >/tmp/adss_upgrade.log 2>&1")
    http.redirect(dispatcher.build_url("admin", "services", "adss", "upgrade_info"))
end

return m