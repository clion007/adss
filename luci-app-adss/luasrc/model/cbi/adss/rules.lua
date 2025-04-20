local m, s, o

m = Map("adss", translate("规则管理"))

s = m:section(TypedSection, "source", translate("自定义规则源"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

o = s:option(Value, "name", translate("名称"))
o.rmempty = false

o = s:option(Value, "url", translate("URL"))
o.rmempty = false

s = m:section(TypedSection, "custom", translate("自定义规则"))
s.anonymous = true

o = s:option(TextValue, "userwhitelist", translate("白名单"),
    translate("每行一个域名，不含http://等前缀"))
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section)
    return nixio.fs.readfile("/etc/dnsmasq.d/adss/rules/userwhitelist") or ""
end
o.write = function(self, section, value)
    nixio.fs.writefile("/etc/dnsmasq.d/adss/rules/userwhitelist", value:gsub("\r\n", "\n"))
end

o = s:option(TextValue, "userblacklist", translate("黑名单"),
    translate("每行一个域名，不含http://等前缀"))
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section)
    return nixio.fs.readfile("/etc/dnsmasq.d/adss/rules/userblacklist") or ""
end
o.write = function(self, section, value)
    nixio.fs.writefile("/etc/dnsmasq.d/adss/rules/userblacklist", value:gsub("\r\n", "\n"))
end

return m