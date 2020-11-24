package NetlifyBuildHooks::CMS;
use strict;

use MT;
use MT::EntryStatus qw(:all);

use constant NetlifyBuildHooksUrl => 'https://api.netlify.com/build_hooks/';
use HTTP::Request::Common;
use JSON;

sub request {
    my ($id) = @_;
    require MT::Util::Log;
    MT::Util::Log->init();
    my $plugin = MT->component('NetlifyBuildHooks');
    my $app_id = $plugin->get_config_value($id, 'system');
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
    return 1 unless request('netlify_build_hooks_develop');
}

1
