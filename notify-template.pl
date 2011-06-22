#!/usr/bin/perl
#
# notify-template.pl - Use perl's Template::Toolkit to more easily define and manage nagios/icinga notifications

use strict;
use Getopt::Long;
use Template;
use Sys::Hostname;

my $baseurl;
my $template;
GetOptions(
		'baseurl=s' => \$baseurl,
		'template=s'=> \$template );

sub usage {
	"Usage: $0 --template=<path_to_template> [--baseurl=https://monitoring.host[/subfolder]]\n";
}

if(!-r $template) {
		print &usage;
		print "ERROR: Template not found or not readable by effective user\n";
		exit(1);
}

# Remove the specific 'NAGIOS_' or 'ICINGA_' portion of the macro names
my $VARS = {
		BASEURL => $baseurl,
		LOCALHOST => hostname };

for my $key (keys %ENV) {
		if ($key =~ /^(icinga|nagios)_/i) {
				my $generic_key = $key;
				$generic_key =~ s/^(icinga|nagios)_//i;
				$VARS->{$generic_key} = $ENV{$key};
		}
}

# Use Template::Toolkit to parse $template and print the result to STDOUT
my $tt = Template->new({ABSOLUTE=>1});
$tt->process($template, $VARS) || die $tt->error();

