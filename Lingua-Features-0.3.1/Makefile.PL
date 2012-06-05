# $Id: Makefile.PL,v 1.8 2006/08/22 14:13:40 rousse Exp $

use ExtUtils::MakeMaker;
eval {
    require ExtUtils::MakeMaker::Coverage;
    import ExtUtils::MakeMaker::Coverage;
};

WriteMakefile(
    NAME          => 'Lingua::Features',
    VERSION_FROM  => 'lib/Lingua/Features.pm',
    ABSTRACT_FROM => 'lib/Lingua/Features.pm',
    AUTHOR        => 'Guillaume Rousse <grousse@cpan.org>',
    PREREQ_PM     => {
        'XML::Generator' => 0,
        'Tie::IxHash'    => 0,
        'List::Compare'  => 0,
        'Test::More'     => 0,
    },
    dist           => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
    },
    clean          => {
        FILES => 'Lingua-Features-*'
    },
);
