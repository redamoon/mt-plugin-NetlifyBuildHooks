package NetlifyBuildHooks::CMS;
use strict;

use MT;

use constant NetlifyBuildHooksUrl => 'https://api.netlify.com/build_hooks/';
use HTTP::Request::Common;
use JSON;

sub instance { MT->instance->component('NetlifyBuildHooks'); }

sub request {
    my ($id) = @_;
    require MT::Util::Log;
    MT::Util::Log->init();
    my $plugin = MT->component('NetlifyBuildHooks');
    my $app_id = $plugin->get_config_value($id);
    MT::Util::Log->info('NetlifyBuildHooks: no app_id') unless $app_id;
    return unless $app_id;

    my $url = NetlifyBuildHooksUrl . $app_id; #webhook url
    my $ua = MT->new_ua( { timeout => 10 } );
    return unless $ua;
    my $request = POST($url, Content_Type => 'application/json', Content => encode_json({}));
    my $response = $ua->request($request);
    return unless $response->is_success();
    return 1;
}

# 設定一覧
sub setting {
    my $app = shift;
    my $plugin = MT->component('NetlifyBuildHooks');
    $app->add_breadcrumb($plugin->translate('Netlify Build Hooks Plugin'));
    return instance->load_tmpl('netlify_build.tmpl');
}

# 本番サイトを保存する
sub production {
    my $app = shift;
    $app->add_return_arg(save_production => 1);
    request('netlify_build_hooks_production');
    $app->call_return;
}

# 開発サイトを保存する
sub develop {
    my $app = shift;
    $app->add_return_arg(save_develop => 1);
    request('netlify_build_hooks_develop');
    $app->call_return;
}

1
