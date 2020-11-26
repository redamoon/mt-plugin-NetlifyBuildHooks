package NetlifyBuildHooks::CMS;
use strict;

use MT;

use constant NetlifyBuildHooksUrl => 'https://api.netlify.com/build_hooks/';
use HTTP::Request::Common;
use JSON;

sub plugin {
    return MT->component('NetlifyBuildHooks');
}
sub instance { MT->instance->component('NetlifyBuildHooks'); }
sub get_blog_id {
    my $app = shift;
}

sub request {
    my ($key, $blog_id) = @_;
    require MT::Util::Log;
    MT::Util::Log->init();
    my $plugin = plugin();
    my $app_id = $plugin->get_config_value($key, 'blog:' . $blog_id);
    MT::Util::Log->info('NetlifyBuildHooks: no app_id') unless $app_id;
    return unless $app_id;

    # webhook url
    my $url = NetlifyBuildHooksUrl . $app_id;
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
    my $blog = $app->blog;
    my $blog_id;
    $blog_id = $blog->id;
    $app->add_return_arg(save_production => 1);
    request('netlify_build_hooks_production', $blog_id);
    $app->call_return;
}

# 開発サイトを保存する
sub develop {
    my $app = shift;
    my $blog = $app->blog;
    my $blog_id;
    $blog_id = $blog->id;
    $app->add_return_arg(save_develop => 1);
    request('netlify_build_hooks_develop', $blog_id);
    $app->call_return;
}

1
