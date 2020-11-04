package NetlifyBuildHooks::Callbacks;
use strict;

use constant NetlifyBuildHooksUrl => 'https://api.netlify.com/build_hooks/';
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;

sub post_save_entry {
    my ($cb, $app, $obj, $org_obj) = @_;
    my $plugin = MT->component('NetlifyBuildHooks');
    require MT::Entry;
    return unless $obj->status == MT::Entry::RELEASE();

    my $app_id = $plugin->get_config_value('netlify_build_hooks', 'system');
    return 1 unless $app_id;

    my $url = NetlifyBuildHooksUrl . $app_id; #webhook url
    my $request = POST($url, Content_Type => 'application/json', Content => encode_json({}));

    my $ua = LWP::UserAgent->new;

    $obj->save
        or die $obj->errstr;
    $ua->request($request);
}

1;

