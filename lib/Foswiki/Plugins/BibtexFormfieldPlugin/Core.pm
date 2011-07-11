# See bottom of file for default license and copyright information

=begin TML

---+ package Foswiki::Plugins::BibtexFormfieldPlugin::Core

=cut

package Foswiki::Plugins::BibtexFormfieldPlugin::Core;

# Always use strict to enforce variable scoping
use strict;
use warnings;

use Error;
use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version
use Foswiki::Form();

sub beforeSaveHandler {
    my ( $text, $topic, $web, $topicObject ) = @_;
    my $formData = $topicObject->get('FORM');
    my $formWeb;
    my $formTopic;
    my $formTopicObject;
    my $formDef;

    if ( defined $formData and $formData->{name} ) {
        ( $formWeb, $formTopic ) =
          Foswiki::Func::normalizeWebTopicName( $web, $formData->{name} );

        try {
            $formDef = Foswiki::Form->new( $Foswiki::Plugins::SESSION, $formWeb,
                $formTopic );
        }
        catch Foswiki::OopsException with {

            # Form definition not found, ignore
            my $e = shift;
            Foswiki::Func::writeDebug(
"ERROR: BibtexFormfieldPlugin can't read form definition for $formWeb.$formTopic"
            );
        };

        if ( $formDef and $formDef->getFields() )
        {    # form definition found, if not the formfields aren't indexed
            my @fieldDefs = @{ $formDef->getFields() };
            my $bibtexFieldName;

            while ( not $bibtexFieldName and scalar(@fieldDefs) ) {
                my $fieldDef = pop(@fieldDefs);

                if ( $fieldDef->{type} and $fieldDef->{type} eq 'bibtex' ) {
                    $bibtexFieldName = $fieldDef->{name};
                }
            }
            if ($bibtexFieldName) {
                my $bibtext = $topicObject->get( 'FIELD', $bibtexFieldName );
                my @pairs;
            }
        }
    }

    return;
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2011-2011 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
