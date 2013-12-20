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
use Groups;

my( @sources, $lex, $version );

if( @ARGV ) {
   die( "usage: $0 version source1 source2... lex\n" ) unless( scalar @ARGV >= 4 );
   @sources = @ARGV;
   $version = shift( @sources );
   $lex = pop( @sources );

} else {
   die( "DEVDIR not set.\n" ) unless( $dd );
   @sources = (
      "$dd/products/zxtm/lb/functions.cpp", 
      "$dd/products/zxtm/ichor/funs.cpp"
   );
   $lex = "$dd/products/zxtm/ichor/lex.l";
   $version = `cat $dd/products/version | egrep 'ZXTM_RELEASE ' | awk '{print \$3}'`;
   chomp( $version );
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
               if( $buffer =~ /^($paramRegex)$/ ) {
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

my @keyWords;
open( LEX, $lex ) or die( "Could not read lex.l: $!\n" ); 
my $startComment = 0;

foreach ( <LEX> ) {
   if( !$startComment && /Built-in keywords/i ) {
      $startComment = 1;
   } elsif( $startComment && /^\s*"(\w+)"/ ) {
      push( @keyWords, $1 );
   } elsif( $startComment && /\s*\/\*/ ) {
      last;
   }
}

close( LEX );

print STDERR "Keywords: " . join( ', ', @keyWords ) . "\n";

# -----------------------------------------------------------------------------
# Process data and format into XML
my $errors = '';

my $xml = new XML::Writer( DATA_MODE => 1, DATA_INDENT => 3 );

$xml->xmlDecl();

$xml->startTag( 'codedata', lang => 'en_us', version => $version );

$xml->startTag( 'keywords' );
foreach my $keyword ( @keyWords ) {
   $xml->emptyTag( 'keyword', name => $keyword );
}
$xml->endTag( 'keywords' );

print "\n";

my $funcCount = 0;

$xml->startTag( 'groups' );
foreach my $group ( sort keys %codeGroups )
{
   $xml->startTag( 'group', name => $group );
   my $functions = $codeGroups{$group};
   
   $xml->startTag( 'description' );
   my $desc = $groupDesc{$group} || '';
   $xml->characters( $desc );
   $errors .= "WARN: Group '$group' has no description.\n" if( $desc eq '' );
   $xml->endTag( 'description' );

   $xml->startTag( 'functions' );
   foreach my $function ( sort keys %$functions ) 
   {
      $xml->startTag( 'func', name => $function );
      $funcCount++;

      my $funcData = $functions->{$function};
      my $ichorDocs = $funcData->{fdata};
      my $restrictions = $funcData->{restrictions};
      my( $minParams, $maxParams, $regex ) = ( 
         $funcData->{paramMin}, $funcData->{paramMax}, $funcData->{paramRegex}
      );
      
      ### Parameters ###
      $xml->startTag( 'parameters', min => $minParams, max => $maxParams, regex => $regex );
      my $numParams = ($ichorDocs->NUMPARAMS || 0 );
      
      for( my $i = 0; $i < $numParams; $i++ ) {
         my $param = $ichorDocs->PARAMS($i)->NAME;
         $param =~ s/^[^\w_]+|[^\w_]+$//g;
         #$param =~ s/\s+/_/g;
         #$param = join( '', map { ucfirst $_; } split( /\s+/, "!$param" ) );
         #$param =~ s/[^\w_]//g;

         if( $param eq '' ) {
            $numParams--;
            next;
         }
         $xml->emptyTag( 'param', name => $param );
      }

      if( $maxParams ne 'INF' && $maxParams > $numParams ) {
         $errors .= "WARN: Missing parameters for '$function'\n";
         for( my $i = 0; $i < $maxParams - $numParams; $i++ ) {
            $xml->emptyTag( 'param', name => 'value' );
         }
      }
      $xml->endTag( 'parameters' );      

      ### Restrictions ###
      $xml->startTag( 'restrictions' );
      foreach my $restriction ( @$restrictions ) {
         $xml->emptyTag( 'restriction', type => $restriction );
      }
      $xml->endTag( 'restrictions' );  

      ### Description ###
      $xml->startTag( 'description' );
      my $desc = $ichorDocs->DESCRIPTION;
      if( $ichorDocs->REPLACEDBY ) {
         $desc .= "<p><b>Function is deprecated.</b><br />Replaced by ". $ichorDocs->REPLACEDBY ."</p>"
      }
      $desc =~ s/\s+/ /g;
      $xml->characters( $desc );

      $xml->endTag( 'description' );  

      ### Related Functions ###
      $xml->startTag( 'relatedFunctions' );
      foreach my $related ( split( /[\s,]+/, $ichorDocs->SEEALSO || '' ) ) {
         $xml->emptyTag( 'related', func => $related );
      }
      $xml->endTag( 'relatedFunctions' );  
      


      $xml->endTag( 'func' );
   }
   $xml->endTag( 'functions' );

   $xml->endTag( 'group' );
}
$xml->endTag( 'groups' );

$xml->endTag( 'codedata' );
print "\n";

print STDERR "Complete. Parsed $funcCount functions.\n";
print STDERR $errors;

