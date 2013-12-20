#!/usr/bin/perl -w

use strict;

my $dd;
BEGIN {
   $dd = $ENV{DEVDIR};
   push( @INC, "$dd/products/zxtm/docsrc" );
} 

use ichordocs::IchorDocs;
use ichordocs::FnDefn;
use ichordocs::Param;
use Data::Dumper;
use XML::Writer;
use IO::File;

use Groups;

my( @sources, $dest, $toc );

if( @ARGV ) {
   die( "useage: $0 version source1 source2 lex\n" ) unless( scalar @ARGV == 4 );
   @sources = ( $ARGV[1], $ARGV[2] );

} else {
   die( "DEVDIR not set.\n" ) unless( $dd );
   @sources = (
      "$dd/products/zxtm/lb/functions.cpp", 
      "$dd/products/zxtm/ichor/funs.cpp"
   );
   $dest = "$dd/products/zxtm/tools/eclipse-plugin/plugin-project/help/ts";
   $toc = "$dd/products/zxtm/tools/eclipse-plugin/plugin-project/ts-toc.xml";
}

my %groupDesc = Groups::Descriptions();

# -----------------------------------------------------------------------------
# Processing source files

my %codeGroups;
foreach my $sourceFile ( @sources ) {

   open( SRC, $sourceFile ) or die( "Could not open source file '$sourceFile': $!\n" );
   my $source = "";
   foreach ( <SRC> ) {
      $source .= $_;
   }
   close( SRC );

   my $codeData = ichordocs::IchorDocs::parse( $source, 0 );

   foreach my $group ( keys %$codeData ) {
      my $functions = $codeData->{$group};

      foreach my $function ( keys %$functions ) {
         my $functionData = $functions->{$function};

         $codeGroups{$group}->{$function}->{fdata} = $functionData;

         if( $source =~ /install_function\s*\(\s*"\Q$function\E"\s*,\s*"([^"]*)"\s*,\s*[^\s,]+\s*(,\s*([^\)]+))?/i ) {
            my( $paramRegex, $restrictions ) = ( $1, $3 );

            my( $min, $max, $buffer ) = ( -1, 0, "" );
            for( my $i = 0; $i <= 20; $i++ ) {
               if( $buffer =~ /^$paramRegex$/ ) {
                  $min = $i if( $min == -1 );
                  $max = $i;
               }
               $buffer .= "#";
            }

            $max = 'INF' if( $max == 20 );

            $codeGroups{$group}->{$function}->{paramMin} = $min;
            $codeGroups{$group}->{$function}->{paramMax} = $max;
            $codeGroups{$group}->{$function}->{paramRegex} = $paramRegex;

            $codeGroups{$group}->{$function}->{restrictions} = 
               [ split( /[\s\|]+/, $restrictions ) ];

         } else {
            print "ERROR: No install_function for '$function' in '$sourceFile'\n";
         }
      }
   }
}

# -----------------------------------------------------------------------------
# Process data and format into HTML Files
my $errors = '';

my %children;

foreach my $group ( sort keys %codeGroups )
{
   my $output = '';
   my $functions = $codeGroups{$group};

   my $xml = new XML::Writer( DATA_MODE => 1, DATA_INDENT => 3, OUTPUT => \$output, UNSAFE => 1 );
   $xml->startTag( 'html' );

   $xml->startTag( 'header' );
   $xml->dataElement( 'title', $group );
   $xml->emptyTag( 'link', rel => 'stylesheet', href => "../../../PRODUCT_PLUGIN/book.css" );
   $xml->endTag( 'header' );

   $xml->startTag( 'body' );
   
   $xml->dataElement( 'h2', $group );
   $xml->raw( "\n" );

   $xml->dataElement( "div", $groupDesc{$group} || '', class => "groupDescription" );

   # Contents
   $xml->dataElement( 'h3', "Contents" );

   $xml->startTag( 'ul' );
   foreach my $function ( sort keys %$functions ) {
      $xml->startTag( 'li' );
      $xml->dataElement( 'a', $function, href => "#$function" );
      $xml->endTag( 'li' );
   }
   $xml->endTag( 'ul' );

   $xml->raw( "\n" );

   # Function Docs  
   $xml->dataElement( 'h3', "Function Documentation" );
   foreach my $function ( sort keys %$functions ) {
      my $funcData = $functions->{$function};
      my $ichorDocs = $funcData->{fdata};
      my $numParams = ($ichorDocs->NUMPARAMS || 0 );

      # Process Parameters
      my( $minParams, $maxParams, $regex ) = ( 
         $funcData->{paramMin}, $funcData->{paramMax}, $funcData->{paramRegex}
      );

      my @params;
      for( my $i = 0; $i < ($ichorDocs->NUMPARAMS || 0); $i++ ) {
         my $param = $ichorDocs->PARAMS($i)->NAME;

         if( $param eq '' ) {
            $numParams--;
            next;
         }  
         
         push( @params, $param );
      }

      if( $maxParams ne 'INF' && $maxParams > $numParams ) {
         $errors .= "WARN: Missing parameters for '$function'\n";
         for( my $i = 0; $i < $maxParams - $numParams; $i++ ) {
            push( @params, 'value' );
         }
      }

      # Print function docs
      $xml->startTag( 'div', class => "functionDoc", id => $function );   
      $xml->dataElement( 'h4', "$function( " . join( ', ', @params ) . " )" );

      $xml->startTag( 'div', class => "functionDescription" );   
      $xml->raw( $ichorDocs->DESCRIPTION );

      if( $ichorDocs->REPLACEDBY ) {
         $xml->raw( "<p>This function has been deprecated; ",
                    "<a href=\"\#", lc($ichorDocs->REPLACEDBY), "\">", $ichorDocs->REPLACEDBY,
                    "</a> should be used instead.</p>" );
      } else {
         $xml->raw( "<pre>".$ichorDocs->SAMPLE."</pre>" );

         if( $ichorDocs->SHORTCUT ) {
            $xml->raw( "<b>Alternate name:</b> " . $ichorDocs->SHORTCUT . "<br>\n" );
         }

         # See also links
         if( defined $ichorDocs->SEEALSO ) {
            $xml->raw( "<b>See also:</b> " );
            my @also;
            foreach( split /[\s,]+/, $ichorDocs->SEEALSO ) {
               my $linkGroup = $group;
               if( /([\w\.]+)\.\w+/ ) {
                  $linkGroup = $1;
               }
               push( @also, qq|<a href="./$linkGroup.html#$_">$_</a>| );
            }
            $xml->raw( join ", ", @also );
         }

      }
      $xml->endTag( 'div' );

      $xml->endTag( 'div' );
      $xml->raw( "\n" );
   }

   $xml->endTag( 'body' );

   $xml->endTag( 'html' );

   if( !open( HTML, "> $dest/$group.html" ) ) {
      print STDERR "Could not open '$dest/$group.html': $!\n";
      next;
   }
   print HTML $output . "\n";
   close( HTML );   

   if( $group =~ /((\w+\.)+)\w+/ ) {
      my $parent = $1;
      $parent =~ s/\.$//;
      #print "$group parent is $parent\n";

      push( @{$children{$parent}}, $group );
   } else {
      push( @{$children{__root__}}, $group );
      #print "$group is root\n";
   }
}

# -----------------------------------------------------------------------------
# Add table of contents XML file.

sub printGroups($$);

sub printGroups($$)
{
   my( $xml, $parent ) = @_;
   foreach my $group( sort @{$children{$parent}} ) {    

      if( $children{$group} && scalar @{$children{$group}} > 0 ) {
         $xml->startTag( 'topic', label => $group, href => "help/ts/$group.html" );
         printGroups( $xml, $group );
         $xml->endTag( 'topic' );
      } else {
         $xml->emptyTag( 'topic', label => $group, href => "help/ts/$group.html" );
      }
   }
}


my $output = '';
my $xml = new XML::Writer( DATA_MODE => 1, DATA_INDENT => 3, OUTPUT => \$output );
$xml->startTag( 'toc', label => "TrafficScript Reference" );

printGroups( $xml, '__root__' );

$xml->endTag( 'toc' );

if( !open( TOC, "> $toc" ) ) {
   print STDERR "Could not open '$toc': $!\n";
} else {
   print TOC $output . "\n";
   close( TOC ); 
}



#print STDERR "Complete. Parsed $funcCount functions.\n";
print STDERR $errors;

