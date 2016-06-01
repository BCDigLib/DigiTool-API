#!/usr/bin/perl -w
   
use strict;
use SOAP::Lite;
use FileHandle;

my %pidtomid;
main();

#-----------------------------------------------------------------------------
sub main {
    
    usage()
        if !(@ARGV);
        
    my ($owner, $pidlist) = @ARGV;
    my ($server, $DEMendpoint);
    $server     = 'http://dcollections.bc.edu';
    $DEMendpoint   = $server . '/de_repository_web/services/DigitalEntityManager';   
    
    my ($generalFileName, $deCallFileName);
  
    readMID($pidlist);
    
    $generalFileName = readXML('general.xml'); 
    $generalFileName =~ s/XXXXX/$owner/;
    
    $deCallFileName = readXML('deMetaDeleteCall.xml');
  
    while(my ($keyPid, $mid) = each(%pidtomid)) {

        my $newdeCall;
        ($newdeCall = $deCallFileName) =~ s/#####/$keyPid/;
        ($newdeCall = $newdeCall) =~ s/@@@@@/$mid/;

         print "Updating $keyPid\n";
         print SOAP::Lite
         -> uri('DigitalEntityManager')
         -> proxy($DEMendpoint)
         -> digitalEntityCall($generalFileName, $newdeCall)
         -> result
         ;
    }
}

#-----------------------------------------------------------------------------
sub readXML
{
    my $file = shift;
    my $fh = new FileHandle();
    $fh->open($file);
    return join "", $fh->getlines();

}

#-----------------------------------------------------------------------------
sub readMID
{
    my $file = shift;
    my $fh = new FileHandle();
    $fh->open($file);
    
    while( not($fh->eof()) )
    {
       my $line = $fh->getline();
       my ($pid, $mid) = split(/\|/, $line);
       chomp $mid;
       $pidtomid{$pid} = $mid;
    }    
}

#-----------------------------------------------------------------------------
sub usage
{
    	print "\n\n-----------------------------------------------------------------\n";
	print "Usage: deleteMID.pl lookupfile\n\n";
	print "Where lookupfile is pipe delimited file containing PID|MID pairs\n";
        print "MID is Metadata to be deleted\n";
	exit 1;
}

