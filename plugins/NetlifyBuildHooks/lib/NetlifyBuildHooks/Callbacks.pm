package NetlifyBuildHooks::Callbacks;
use strict;

use constant NetlifyBuildHooksUrl => 'https://api.netlify.com/build_hooks/';
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;

my $plugin = MT->component('NetlifyBuildHooks');
my $app_id = $plugin->get_config_value('netlify_build_hooks', 'system');
my $url = NetlifyBuildHooksUrl . $app_id; #webhook url
my $request = POST($url, Content_Type => 'application/json', Content => encode_json({}));

sub entry_page_builds {
    my ($cb, $app, $obj, $org_obj) = @_;
    require MT::Entry;
    return unless $obj->status == MT::Entry::RELEASE();
    return 1 unless $app_id;

    my $ua = LWP::UserAgent->new;

    $obj->save
        or die $obj->errstr;
    $ua->request($request);
}

sub content_data_builds {
    my ($cb, $app, $obj, $org_obj) = @_;
    require MT::ContentStatus;
    return unless $obj->status == MT::ContentStatus::RELEASE();
    return 1 unless $app_id;

    my $ua = LWP::UserAgent->new;

    $ua->request($request);
    $obj->save
        or die $obj->errstr;
}

# delete処理
sub delete_builds {
    my $ua = LWP::UserAgent->new;
    $ua->request($request);
}

1;

