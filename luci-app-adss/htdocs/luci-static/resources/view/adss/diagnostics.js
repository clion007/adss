'use strict';
'require view';
'require fs';
'require ui';
'require form';

return view.extend({
    render: function() {
        var m, s, o;

        m = new form.Map('adss', _('ADSS 诊断'));

        s = m.section(form.TypedSection, 'diagnostics');
        s.anonymous = true;

        o = s.option(form.Button, '_check_config');
        o.title = _('检查配置');
        o.inputtitle = _('开始检查');
        o.inputstyle = 'apply';
        o.onclick = function() {
            return fs.exec('/usr/share/adss/check_config.sh').then(function(res) {
                ui.showModal(_('配置检查结果'), [
                    E('p', {}, [ res.stdout || _('配置正常') ]),
                    E('div', { 'class': 'right' }, [
                        E('button', {
                            'class': 'btn',
                            'click': ui.hideModal
                        }, [ _('关闭') ])
                    ])
                ]);
            });
        };

        o = s.option(form.Button, '_test_rules');
        o.title = _('测试规则');
        o.inputtitle = _('开始测试');
        o.inputstyle = 'apply';
        o.onclick = function() {
            return fs.exec('/usr/share/adss/test_rules.sh').then(function(res) {
                ui.showModal(_('规则测试结果'), [
                    E('pre', {}, [ res.stdout || _('测试完成') ]),
                    E('div', { 'class': 'right' }, [
                        E('button', {
                            'class': 'btn',
                            'click': ui.hideModal
                        }, [ _('关闭') ])
                    ])
                ]);
            });
        };

        return m.render();
    }
});