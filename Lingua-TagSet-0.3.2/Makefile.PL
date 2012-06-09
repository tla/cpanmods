# $Id: Makefile.PL,v 1.8 2006/08/22 14:21:24 rousse Exp $

use ExtUtils::MakeMaker;
eval {
    require ExtUtils::MakeMaker::Coverage;
    import ExtUtils::MakeMaker::Coverage;
};

WriteMakefile(
    NAME          => 'Lingua::TagSet',
    VERSION_FROM  => 'lib/Lingua/TagSet.pm',
    ABSTRACT_FROM => 'lib/Lingua/TagSet.pm',
    AUTHOR        => 'Guillaume Rousse <grousse@cpan.org>',
    PREREQ_PM     => {
        'Lingua::Features'            => 0.3,
        'Lingua::Features::Structure' => 0,
	'List::MoreUtils'             => 0,
        'Memoize'                     => 0,
        'Test::More'                  => 0,
    },
    dist           => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
    },
    clean          => {
        FILES => 'Lingua-TagSet-*'
    },
);
