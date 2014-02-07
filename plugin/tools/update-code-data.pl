#!/usr/bin/perl -w

use strict;

my $RELEASE_DIR = '/zeus/data/olympus/dev/sw/zxtm/release/';
my $EARLIEST_VERSION = "3.0";

my $dd = $ENV{DEVDIR} || die( "DEVDIR not set.\n" );
my $CODE_DATA_DIR = "$dd/products/zxtm/tools/eclipse-plugin/plugin-project/code-data";
my $XML_GEN = "$dd/products/zxtm/tools/eclipse-plugin/plugin-project/tools/code-data-xml.pl";

# Function prototypes
sub fetchP4File($$$);

my( %release_sort );

## Work out what versions are available. 
opendir( RELEASE, $RELEASE_DIR ) or die( "Could not read release dir: $!\n" );

foreach my $dir ( readdir ( RELEASE ) ) {
   next if( $dir !~ /^\d+\.\d+$/ );

   my $fullpath = "$RELEASE_DIR/$dir";
   next unless( -d $fullpath );
      
   my @stat = stat( $fullpath );
   if( $dir =~ /(\d+)\.(\d+)(r(\d+))?/ ) {
      $release_sort{$dir} = sprintf( "%03d-%03d-%03d-%015d", $1, $2, $4 || 0, $stat[9] );
   } else {
      $release_sort{$dir} = sprintf( "000-000-000-%015d", $stat[9] );
   }
}

closedir( RELEASE );

# Create a sorted list, filter out versions before EARLIEST_VERSION
my @sorted_versions = sort { $release_sort{$a} cmp $release_sort{$b} } keys %release_sort;
my $earliest = $release_sort{$EARLIEST_VERSION};
@sorted_versions = grep { ($release_sort{$_} cmp $earliest) >= 0  } @sorted_versions;

print "Checking for following versions: " . join( ', ', @sorted_versions ) . "\n";

foreach my $version ( @sorted_versions ) {
   if( -e "$CODE_DATA_DIR/${version}_en_us.xml" ) {
      print "$version exists, nothing to do.\n";
      next;
   } else {
      print "\n$version does not exist, trying to create XML file...\n";
   }

   my $tmpDir = "/tmp/code-data-$$-$version";
   mkdir( "/tmp/code-data-$$-$version", 0777 );

   print "Fetching files from perforce depot...\n";
   fetchP4File( $version, "$tmpDir/functions.cpp", "products/zxtm/lb/functions.cpp" ) or next;
   fetchP4File( $version, "$tmpDir/funs.cpp", "products/zxtm/ichor/funs.cpp" ) or next;
   fetchP4File( $version, "$tmpDir/lex.l", "products/zxtm/ichor/lex.l" ) or next;

   print "Generating XML...\n";
   system( "$XML_GEN $version $tmpDir/functions.cpp $tmpDir/funs.cpp $tmpDir/lex.l > $CODE_DATA_DIR/${version}_en_us.xml" );
   system( "rm -rf $tmpDir" );
}

system( "rm -rf /tmp/code-data-$$-* &2>/dev/null &1>/dev/null" );

sub fetchP4File($$$)
{
   my( $version, $out, $path ) = @_;

   my $simpleVersion = $version;
   $simpleVersion =~ s/\.//;

   my $depotPath = "//depot/branches/release/zxtm_$simpleVersion/$path";

   system( "p4 print -q -o $out $depotPath" );
   
   unless( -e $out ) {
      print "ERROR: Fetching $path failed! - $depotPath\n";
      return 0;
   }

   return 1;
}
