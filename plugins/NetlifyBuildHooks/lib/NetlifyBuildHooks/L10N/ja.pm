package NetlifyBuildHooks::L10N::ja;

use strict;
use base 'NetlifyBuildHooks::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (
    'Production'                                                          => '本番',
    'Develop'                                                             => '開発',
    'Production ID'                                                       => '本番環境 ID',
    'Develop ID'                                                          => '開発環境 ID',
    'Production build'                                                    => '本番ビルド',
    'Develop build'                                                       => '開発ビルド',
    'Build'                                                               => 'ビルドする',
    'I ran a development build of Netlify.'                               => 'Netlifyの開発ビルドを実行しました。',
    'I ran a production build of Netlify.'                                => 'Netlifyの本番ビルドを実行しました。',
    'Enter your Netlify Build Hooks ID for your development environment.' => '開発環境のNetlify Build Hooks IDを入力してください。',
    'Enter your production Netlify Build Hooks ID.'                       => '本番環境のNetlify Build Hooks IDを入力してください。',
    'Netlify Build Hooks Plugin'                                          => 'Netlify Build Hooks',
    '_PLUGIN_DESCRIPTION'                                                 => 'Netlify Build Hooksを実行する',
    '_PLUGIN_AUTHOR'                                                      => 'redamoon',
);

1;
