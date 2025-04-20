'use strict';
'require view';
'require fs';
'require ui';

return view.extend({
    load: function() {
        return Promise.all([
            L.resolveDefault(fs.read('/var/log/adss.log'), ''),
            L.resolveDefault(fs.read('/var/log/adss_update.log'), '')
        ]);
    },

    render: function(data) {
        var logs = data[0] || '';
        var update_logs = data[1] || '';
        
        return E('div', { 'class': 'cbi-map' }, [
            E('h2', _('ADSS 日志')),
            E('div', { 'class': 'cbi-section' }, [
                E('div', { 'class': 'cbi-section-descr' }, _('运行日志')),
                E('pre', { 'id': 'syslog', 'class': 'logs' }, [ logs ]),
                E('div', { 'class': 'cbi-section-descr' }, _('更新日志')),
                E('pre', { 'id': 'updatelog', 'class': 'logs' }, [ update_logs ]),
                E('div', { 'class': 'cbi-section-actions' }, [
                    E('button', {
                        'class': 'btn',
                        'click': ui.createHandlerFn(this, function() {
                            return fs.write('/var/log/adss.log', '').then(function() {
                                return fs.write('/var/log/adss_update.log', '');
                            }).then(function() {
                                ui.addNotification(null, E('p', _('日志已清空')));
                                this.load();
                            }.bind(this));
                        })
                    }, [ _('清空日志') ])
                ])
            ])
        ]);
    }
});