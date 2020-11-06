package NetlifyBuildHooks::Callbacks;
use strict;

use MT;
use MT::EntryStatus qw(:all);

use constant NetlifyBuildHooksUrl => 'https://api.netlify.com/build_hooks/';
use HTTP::Request::Common;
use JSON;

sub request {
    require MT::Util::Log;
    MT::Util::Log->init();
    my $plugin = MT->component('NetlifyBuildHooks');
    my $app_id = $plugin->get_config_value('netlify_build_hooks', 'system');
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

sub post_save_builds {
    my ($cb, $app, $obj, $org_obj) = @_;
    return 1 unless $org_obj && $org_obj->status == MT::EntryStatus::RELEASE();
    require MT::Util::Log;
    MT::Util::Log->init();
    MT::Util::Log->info('NetlifyBuildHooks: post_save:obj:' . ref($obj) . ', status=' . status_text($obj->status));
    MT::Util::Log->info('NetlifyBuildHooks: post_save:org:' . ref($org_obj) . ', status=' . status_text($org_obj->status)) if $org_obj;
    return 1 unless request();
    1;
}

# delete処理
sub delete_builds {
    my ($cb, $app, $obj) = @_;
    my $ua = LWP::UserAgent->new;
    require MT::Util::Log;
    MT::Util::Log->init();
    MT::Util::Log->info('NetlifyBuildHooks: post_delete:' . ref($obj));
    return 1 unless request();
    1;
}

1;
