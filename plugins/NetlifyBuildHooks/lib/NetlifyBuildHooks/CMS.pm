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

sub request {
    my ($key, $blog_id, $save_name, $app, $error_name) = @_;
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

    if ($response->code == 200) {
        $app->add_return_arg($save_name => 1),
    } else {
        $app->add_return_arg($error_name => 1)
    };
    return unless $response->is_success();
    return 1;
}

# 設定一覧
sub setting {
    my $app = shift;
    my $plugin = plugin();
    my $blog = $app->blog;
    my $blog_id;
    $blog_id = $blog->id;
    $app->add_breadcrumb($plugin->translate('Netlify Build Hooks Plugin'));
    my %param = (
        netlify_build_hooks_production => $plugin->get_config_value('netlify_build_hooks_production', 'blog:' . $blog_id),
        netlify_build_hooks_develop    => $plugin->get_config_value('netlify_build_hooks_develop', 'blog:' . $blog_id)
    );
    return instance->load_tmpl('netlify_build.tmpl', \%param);
}

# 本番サイトを保存する
sub production {
    my $app = shift;
    my $blog = $app->blog;
    my $blog_id;
    $blog_id = $blog->id;
    request('netlify_build_hooks_production', $blog_id, 'save_production', $app, 'error_production');
    $app->call_return;
}

# 開発サイトを保存する
sub develop {
    my $app = shift;
    my $blog = $app->blog;
    my $blog_id;
    $blog_id = $blog->id;
    request('netlify_build_hooks_develop', $blog_id, 'save_develop', $app, 'error_develop');
    $app->call_return;
}

1
