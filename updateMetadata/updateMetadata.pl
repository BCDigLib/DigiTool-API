#!/usr/bin/perl -w
   
use strict;
use SOAP::Lite;
use FileHandle;
use encoding "utf-8";

main();

#-----------------------------------------------------------------------------
sub main {
    
    usage()
    	if !(@ARGV);
                
    my ($owner, $dir) = @ARGV;
    my ($server, $DEMendpoint);
    $server     = 'http://dcollections.bc.edu';
    $DEMendpoint   = $server . '/de_repository_web/services/DigitalEntityManager';   
    my $MEMendpoint   = $server . '/de_repository_web/services/MetadataManager';
    
    my ($general, $mdCall);
  
    $general = readXML('general.xml'); 
    $general =~ s/XXXXX/$owner/;
    
    $mdCall = readXML('mdCall.xml');
    
    # Read each MD file in directory
    opendir(D, "$dir") || die "Can't open directory $dir: $!\n";
    my @files = readdir(D);
    closedir(D);
    
    foreach my $file(@files){
        if ($file =~ /^([0-9]+)_([0-9]+)\.xml$/) {
            my ($pid, $mid) = ($1, $2);
            my $metadata = readXML("$dir\\$file");

            my $newmdCall;
            ($newmdCall = $mdCall) =~ s/!!!!!/$pid/;
            ($newmdCall = $newmdCall) =~ s/#####/$mid/;
            ($newmdCall = $newmdCall) =~ s/@@@@@/$metadata/;
        
            print "Updating $pid\n";
            
            my $result = SOAP::Lite
                -> uri('DigitalEntityManager')
                -> proxy($MEMendpoint)
                -> encoding('UTF-8')
                -> digitalEntityCall($general, SOAP::Data->type(string => $newmdCall))
                -> result
            ;

         if ($result) {}
         else {
            print "Failed.\n";
            }
        }
     }
}

#-----------------------------------------------------------------------------
sub readXML
{
    my $file = shift;
    my $fh = new FileHandle();
    $fh->open($file);
    $fh->binmode(':utf8');
    return join "", $fh->getlines();
}

#-----------------------------------------------------------------------------
sub usage {
	
	print "\n\n-----------------------------------------------------------------\n";
	print "Usage: updateMetadata.pl owner directory\n\n";
	print "Where owner is silo \n";
        print "directory is directory containing metadata files. FILES SHOULD BE NAMED WITH THE PID_MID TO UPDATE (1234_5678.xml)\n";
	exit 1;
}




