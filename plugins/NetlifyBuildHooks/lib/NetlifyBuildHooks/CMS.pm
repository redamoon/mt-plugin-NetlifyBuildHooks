package NetlifyBuildHooks::CMS;
use strict;

use MT;
use MT::EntryStatus qw(:all);

use constant NetlifyBuildHooksUrl => 'https://api.netlify.com/build_hooks/';
use HTTP::Request::Common;
use JSON;

sub instance { MT->instance->component('NetlifyBuildHooks'); }

sub request {
    my ($id) = @_;
    require MT::Util::Log;
    MT::Util::Log->init();
    my $plugin = MT->component('NetlifyBuildHooks');
    my $app_id = $plugin->get_config_value($id, 'blog');
    MT::Util::Log->info('NetlifyBuildHooks: no app_id') unless $app_id;
    return unless $app_id;

    my $url = NetlifyBuildHooksUrl . $app_id; #webhook url
    my $ua = MT->new_ua( { timeout => 10 } );
    return unless $ua;
    my $request = POST($url, Content_Type => 'application/json', Content => encode_json({}));
    my $response = $ua->request($request);
    return unless $response->is_success();
    return $id;
}

sub production_build {
    return 1 unless request('netlify_build_hooks_production');
}

sub develop_build {
    request('netlify_build_hooks_develop');
    return instance->load_tmpl('netlify_build.tmpl');
}

sub netlify {
    my $app = shift;
    my $plugin = MT->component('NetlifyBuildHooks');
    my $production_id =  $plugin->get_config_value('netlify_build_hooks_production', 'blog');
    my $develop_id = $plugin->get_config_value('netlify_build_hooks_develop', 'blog');
    my $params = {
        production => $production_id,
        develop   => $develop_id
    };
    $app->build_menus( $params );
    return instance->load_tmpl('netlify_build.tmpl', $params);
}

sub save_production {
    my $app = shift;
    my %param;
    my $q = $app->param;
    my $id = $q->param('blog_id');
    if (!$id) {
        $param{ new_object } = 1;
        $param{ page_title } = MT->translate('Netlify Build Hooks');
    } else {

    }
    $param{ saved } = $q->param('saved');
    my $tmpl = 'netlify_build.tmpl';
    return $app->build_page($tmpl, \%param);
}

1
