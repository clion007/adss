'use strict';
'require view';
'require poll';
'require fs';
'require ui';
'require uci';
'require form';
'require tools.widgets as widgets';

return view.extend({
    handleUpdateRules: function() {
        return fs.exec('/usr/share/adss/rules_update.sh').then(function() {
            ui.showModal(_('规则更新'), [
                E('p', _('规则更新已开始，请稍候...')),
                E('div', { 'class': 'right' }, [
                    E('button', {
                        'class': 'btn',
                        'click': function() {
                            ui.hideModal();
                        }
                    }, _('确定'))
                ])
            ]);
        }).catch(function(err) {
            ui.addNotification(null, E('p', _('规则更新失败：%s').format(err)));
        });
    },

    load: function() {
        return Promise.all([
            L.resolveDefault(fs.stat('/etc/dnsmasq.d/adss/rules/dnsrules.conf'), null),
            L.resolveDefault(fs.stat('/etc/dnsmasq.d/adss/rules/hostsrules.conf'), null),
            uci.load('adss')
        ]);
    },

    poll_status: function(nodes, stat) {
        var running = L.resolveDefault(fs.stat('/var/run/adss.pid'), null);
        
        nodes.status.innerHTML = running ? 
            '<em><span class="label success">%s</span></em>'.format(_('运行中')) :
            '<em><span class="label warning">%s</span></em>'.format(_('已停止'));
            
        nodes.last_update.innerHTML = stat[0] ? 
            new Date(stat[0].mtime * 1000).toLocaleString() :
            _('从未更新');
            
        nodes.rules_count.innerHTML = Promise.all([
            L.resolveDefault(fs.read('/etc/dnsmasq.d/adss/rules/dnsrules.conf'), '').then(function(data) {
                return data.trim().split('\n').length;
            }),
            L.resolveDefault(fs.read('/etc/dnsmasq.d/adss/rules/hostsrules.conf'), '').then(function(data) {
                return data.trim().split('\n').length;
            })
        ]).then(function(counts) {
            return _('DNS规则：%d 条，Hosts规则：%d 条').format(counts[0], counts[1]);
        });
    },

    render: function() {
        var m, s, o;
        var nodes = {};

        m = new form.Map('adss', _('ADSS状态'));

        s = m.section(form.TypedSection, 'basic');
        s.anonymous = true;

        nodes.status = E('div');
        nodes.last_update = E('div');
        nodes.rules_count = E('div');

        o = s.option(form.DummyValue, '_status');
        o.title = _('运行状态');
        o.cfgvalue = function() { return nodes.status };
        o.rawhtml = true;

        o = s.option(form.DummyValue, '_last_update');
        o.title = _('上次更新');
        o.cfgvalue = function() { return nodes.last_update };
        o.rawhtml = true;

        o = s.option(form.DummyValue, '_rules_count');
        o.title = _('规则统计');
        o.cfgvalue = function() { return nodes.rules_count };
        o.rawhtml = true;

        o = s.option(form.Button, '_update');
        o.title = _('规则更新');
        o.inputtitle = _('立即更新');
        o.inputstyle = 'apply';
        o.onclick = ui.createHandlerFn(this, 'handleUpdateRules');

        return m.render().then(L.bind(function(m) {
            poll.add(L.bind(function() {
                return Promise.all([
                    fs.stat('/etc/dnsmasq.d/adss/rules/dnsrules.conf'),
                    fs.stat('/etc/dnsmasq.d/adss/rules/hostsrules.conf')
                ]).then(L.bind(this.poll_status, this, nodes));
            }, this), 5);
            
            return m;
        }, this));
    }
});