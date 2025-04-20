module("luci.controller.adss", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/adss") then
        return
    end

    local page = entry({"admin", "services", "adss"}, alias("admin", "services", "adss", "settings"), _("ADSS广告过滤"), 10)
    page.dependent = true
    page.acl_depends = { "luci-app-adss" }
    
    entry({"admin", "services", "adss", "settings"}, cbi("adss/settings"), _("设置"), 10).leaf = true
    entry({"admin", "services", "adss", "status"}, view("adss/status"), _("状态"), 20).leaf = true
    entry({"admin", "services", "adss", "rules"}, cbi("adss/rules"), _("规则管理"), 30).leaf = true
    entry({"admin", "services", "adss", "logs"}, view("adss/logs"), _("日志"), 40).leaf = true
    entry({"admin", "services", "adss", "update_info"}, cbi("adss/update_info"), _("更新信息"), 50).leaf = true
    entry({"admin", "services", "adss", "status_data"}, call("status_data")).leaf = true
end

function status_data()
    local data = {}
    data.running = luci.sys.call("pidof adss >/dev/null") == 0
    data.last_update = luci.sys.exec("stat -c %Y /etc/dnsmasq.d/adss/rules/dnsrules.conf 2>/dev/null")
    data.dns_count = luci.sys.exec("wc -l /etc/dnsmasq.d/adss/rules/dnsrules.conf 2>/dev/null | awk '{print $1}'")
    data.hosts_count = luci.sys.exec("wc -l /etc/dnsmasq.d/adss/rules/hostsrules.conf 2>/dev/null | awk '{print $1}'")
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(data)
end