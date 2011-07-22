# See bottom of file for default license and copyright information

=begin TML

---+ package Foswiki::Plugins::BibtexFormfieldPlugin::Core

=cut

package Foswiki::Plugins::BibtexFormfieldPlugin::Core;

# Always use strict to enforce variable scoping
use strict;
use warnings;

use Storable;
use Error;
use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version
use Foswiki::Form();

use Text::BibTeX;           # library for parsing bibtex files
use Data::Dumper;           # library for debugging

# How to debug:
#    print STDERR "MESSAGE: SCRIPT CALLED!!!";
# Foswiki::Func::writeDebug("This debug message goes to working/logs/debug.log");

sub beforeSaveHandler {
    my ( $text, $topic, $web, $topicObject ) = @_;
    my $formData = $topicObject->get('FORM');
    my $formWeb;
    my $formTopic;
    my $formTopicObject;
    my $formDef;

    #    Foswiki::Func::writeDebug(
    #       "MESSAGE: SCRIPT CALLED!!!"
    #            );

    #if ( defined $formData and $formData->{name} ) {
    #    Foswiki::Func::writeDebug(
    #         "Some Funky message"
    #        Data::Dumper($topicObj->get($formData->{name}))
    #            );
    #   };

    if ( defined $formData and $formData->{name} ) {
        ( $formWeb, $formTopic ) =
          Foswiki::Func::normalizeWebTopicName( $web, $formData->{name} );

        Foswiki::Func::writeDebug( $formTopic . ' ' . $formWeb );

        if (
            $formDef = Foswiki::Form->new(
                $Foswiki::Plugins::SESSION, $formWeb, $formTopic
            )
          )
        {
            Foswiki::Func::writeDebug("Got form definition!");
        }

#        try {
#            $formDef = Foswiki::Form->new( $Foswiki::Plugins::SESSION, $formWeb, $formTopic );
#        }
#        catch Foswiki::OopsException with {
#
#            # Form definition not found, ignore
#            my $e = shift;
#            Foswiki::Func::writeDebug(
#"ERROR: BibtexFormfieldPlugin can't read form definition for $formWeb.$formTopic"
#            );
#        };

        if ( $formDef and $formDef->getFields() )
        {    # form definition found, if not the formfields aren't indexed
            our @bibtexFieldNames = getBibtexFields( $formDef, $formData );

#            ( $bibtexFragmentFieldName, @bibtexFieldNames ) = getBibtexFields( $formDef, $formData );
            foreach my $name (@bibtexFieldNames) {
                Foswiki::Func::writeDebug("Name of bibtex field:");
                Foswiki::Func::writeDebug($name);
            }

            if ( $formDef->getField('bibtexFragment') ) {
                Foswiki::Func::writeDebug("Found bibtexFragment field!");

                my $field = $topicObject->get( 'FIELD', 'bibtexFragment' );
                our $bibtexFragmentString = $field->{value};

       #                  Foswiki::Func::writeDebug( "THIS IS A SUPER FIELD:" );
                Foswiki::Func::writeDebug($bibtexFragmentString);
            }
        }

  #        Foswiki::Func::writeDebug( "bibtexFragmentString is working!!!" );
  #        Foswiki::Func::writeDebug( our $bibtexFragmentString );
  #        if( my $bibtexFragmentString ){
  #           Foswiki::Func::writeDebug( "bibtexFragmentString is working!!!" );
  #        };

        # PSEUDO CODE!!!
        if ( our $bibtexFragmentString and our @bibtexFieldNames ) {
            Foswiki::Func::writeDebug("In detection loop!!!");
            Foswiki::Func::writeDebug($bibtexFragmentString);

            our $entry = new Text::BibTeX::Entry;
            $entry->parse_s( our $bibtexFragmentString );
            my @fieldList = $entry->fieldlist;

        #                 Foswiki::Func::writeDebug( "THIS IS A SUPER FIELD:" );
            foreach our $fieldName (@fieldList) {
                Foswiki::Func::writeDebug($fieldName);
                Foswiki::Func::writeDebug( $entry->get($fieldName) );

                if ( grep $_ eq $fieldName, @bibtexFieldNames ) {
                    Foswiki::Func::writeDebug("Parsed field in bibtexForm!!!");
                    my $fieldValue = $entry->get($fieldName);

               #                       Foswiki::Func::writeDebug( $fieldName );
               #                       Foswiki::Func::writeDebug( $fieldValue );
                    $topicObject->putKeyed( 'FIELD',
                        { name => $fieldName, value => $fieldValue } );
                }

#                 for my $fieldName ( @bibtexFieldNames ){
#                    $entry->fieldlist;
#$entry->get( $field )
#                    if ( parsedEntry->$fieldName ){
#                       $topicObj->putKeyed('FIELD', {name => $fieldName, value => parsedEntry->$fieldName});
#                    };
            }
        }

        #        };
    }

    #
    return;
}

sub getBibtexFields {
    my ( $formDef, $formData ) = @_;
    my @bibtexFieldNames;
    my $bibtexFragmentFieldName;
    my @fieldDefs = @{ $formDef->getFields() };

    Foswiki::Func::writeDebug("Got form field definitions!");

    while ( @fieldDefs != 0 ) {
        my $fieldDef = pop(@fieldDefs);

#      Foswiki::Func::writeDebug($fieldDef->{type});
#      Foswiki::Func::writeDebug($fieldDef->{name});
#if ( $fieldDef->{type} and ( $fieldDef->{type} eq 'textarea+bibtex' or $fieldDef->{type} eq 'bibtex+textarea' ) and $fieldDef->{name} ne 'bibtexFragment' ) {
        if (
                $fieldDef->{name} ne 'bibtexFragment'
            and $fieldDef->{type}
            and (  $fieldDef->{type} eq 'textarea+bibtex'
                or $fieldDef->{type} eq 'bibtex+textarea'
                or $fieldDef->{type} eq 'text+bibtex'
                or $fieldDef->{type} eq 'bibtex+text' )
          )
        {
            Foswiki::Func::writeDebug("In bibtexFragment IF-clause:");
            Foswiki::Func::writeDebug( $fieldDef->{name} );
            push( @bibtexFieldNames, $fieldDef->{name} );
        }

    }

    return (@bibtexFieldNames);

    # return ( $bibtexFragmentFieldName, @bibtexFieldNames );

}

#      if ( $fieldDef->{type} and ( $fieldDef->{type} eq 'textarea+bibtex' or $fieldDef->{type} eq 'bibtex+textarea' ) and $fieldDef->{name} eq 'bibtexFragment' ) {
#          Foswiki::Func::writeDebug( "In bibtexFragment IF-clause:" );
#          Foswiki::Func::writeDebug( $fieldDef->{name} );
#      };
#
#   return ( $bibtexFragmentFieldName, @bibtexFieldNames );
#
#   };
#};

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
