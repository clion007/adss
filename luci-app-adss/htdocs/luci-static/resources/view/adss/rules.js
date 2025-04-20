'use strict';
'require view';
'require form';
'require tools.widgets as widgets';
'require fs';
'require ui';

return view.extend({
    render: function() {
        var m, s, o;

        m = new form.Map('adss', _('ADSS规则管理'),
            _('在这里管理ADSS的规则源和自定义规则'));

        // 规则源管理
        s = m.section(form.GridSection, 'source', _('规则源管理'));
        s.anonymous = true;
        s.addremove = true;
        s.sortable = true;

        o = s.option(form.Flag, 'enabled', _('启用'));
        o.rmempty = false;
        o.default = '1';

        o = s.option(form.Value, 'name', _('名称'));
        o.rmempty = false;

        o = s.option(form.Value, 'url', _('URL'));
        o.rmempty = false;

        // 自定义规则管理
        s = m.section(form.NamedSection, 'custom', 'custom', _('自定义规则'));
        s.anonymous = true;

        o = s.option(form.TextValue, '_whitelist', _('白名单'),
            _('每行一个域名，不含http://等前缀'));
        o.rows = 15;
        o.wrap = 'off';
        o.cfgvalue = function(section_id) {
            return fs.trimmed('/etc/dnsmasq.d/adss/rules/userwhitelist');
        };
        o.write = function(section_id, value) {
            return fs.write('/etc/dnsmasq.d/adss/rules/userwhitelist', value.trim().replace(/\r\n/g, '\n') + '\n');
        };

        o = s.option(form.TextValue, '_blacklist', _('黑名单'),
            _('每行一个域名，不含http://等前缀'));
        o.rows = 15;
        o.wrap = 'off';
        o.cfgvalue = function(section_id) {
            return fs.trimmed('/etc/dnsmasq.d/adss/rules/userblacklist');
        };
        o.write = function(section_id, value) {
            return fs.write('/etc/dnsmasq.d/adss/rules/userblacklist', value.trim().replace(/\r\n/g, '\n') + '\n');
        };

        return m.render();
    }
});