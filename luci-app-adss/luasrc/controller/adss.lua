-- 导入必要的LuCI模块
local nixio = require "nixio"
local http = require "luci.http"
local util = require "luci.util"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local i18n = require "luci.i18n"
local dispatcher = require "luci.dispatcher"

-- 从dispatcher模块导入需要的函数
local entry = dispatcher.entry
local call = dispatcher.call
local firstchild = dispatcher.firstchild
local cbi = dispatcher.cbi

local function _(...)
    return i18n.translate(...)
end

-- 将函数定义为局部函数
local function index()
    if not nixio.fs.access("/etc/config/adss") then
        return
    end
    
    local page = entry({"admin", "services", "adss"}, firstchild(), _("ADSS广告过滤"), 10)
    page.dependent = true
    page.acl_depends = { "luci-app-adss" }
    
    entry({"admin", "services", "adss", "settings"}, cbi("adss/settings"), _("设置"), 10).leaf = true
    entry({"admin", "services", "adss", "status"}, cbi("adss/status"), _("状态"), 20).leaf = true
    entry({"admin", "services", "adss", "rules"}, cbi("adss/rules"), _("规则管理"), 30).leaf = true
    entry({"admin", "services", "adss", "update_info"}, cbi("adss/update_info"), nil).leaf = true
    entry({"admin", "services", "adss", "upgrade_info"}, cbi("adss/upgrade_info"), nil).leaf = true
    
    entry({"admin", "services", "adss", "status_data"}, call("status_data")).leaf = true
end

-- 将函数定义为局部函数
local function status_data()
    local data = {
        running = (sys.call("pidof adss >/dev/null") == 0),
        enabled = (uci:get("adss", "basic", "enabled") == "1")
    }
    http.prepare_content("application/json")
    http.write_json(data)
end

-- 返回包含这些函数的表
return {
    index = index,
    status_data = status_data
}