#!/usr/bin/env perl

use inc::Module::Install;
author( 'NAMER Fiammetta <fiammetta.namer@univ-nancy2.fr>' );
license( 'GPL' );
perl_version( '5.8.1' );
all_from( 'lib/Flemm.pm' );
requires( 'IO::File' );
&WriteAll;
