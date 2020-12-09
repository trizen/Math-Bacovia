
use utf8;
use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
     module_name        => 'Math::Bacovia',
     license            => 'artistic_2',
     dist_author        => q<Daniel Șuteu <trizen@cpan.org>>,
     dist_version_from  => 'lib/Math/Bacovia.pm',
     release_status     => 'stable',

     dynamic_config    => 0,
     extra_manify_args => { utf8 => 1 },

     meta_merge => {
                   resources => {
                                 bugtracker => "https://github.com/trizen/Math-Bacovia/issues",
                                 homepage   => "https://github.com/trizen/Math-Bacovia",
                                 repository => "https://github.com/trizen/Math-Bacovia",
                                },
                  },

     configure_requires => {
                            'Module::Build' => 0,
                           },
     build_requires => {
                        'Test::More' => 0,
                       },
     requires => {
                  'perl'                => 5.014,
                  'Math::AnyNum'        => 0.14,
                  'List::UtilsBy'       => 0.06,
                  'Set::Product::XS'    => 0.04,
                  'Class::Multimethods' => 1.70,
                 },
     add_to_cleanup     => ['Math-Bacovia-*'],
     create_makefile_pl => 'traditional',
);

$builder->create_build_script();
