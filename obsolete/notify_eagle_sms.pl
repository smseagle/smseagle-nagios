#!/usr/bin/perl
# 
# ============================== SUMMARY =====================================
#
# Summary : This plugin sends SMS alerts with SMSEagle hardware sms gateway
# Program : notify_eagle_sms.pl
# Version : 2.0
# Date : 30.12.2020
# Author : RJ / SMSEAGLE.EU 
# Forked from: Nagios-SMS-WT (https://github.com/m-r-h/Nagios-SMS-WT)
# License : BSD
# Copyright (c) 2020, SMSEagle www.smseagle.eu
#
# ============================= MORE INFO ======================================
#
# Visit: https://www.smseagle.eu
#
# README file and the latest version of this plugin can be found on:
# https://bitbucket.org/proximus/smseagle-nagios
#
# ============================= SCRIPT ==========================================
# Script params description:
#
# smseagleurl = URL of your SMSEagle device (eg.: http://192.168.1.150)
# apitoken = SMSEagle API token
# dstaddr = Destination mobile number (the number to send SMS to)
# txt = the text message body

use strict;
use LWP::Simple;
use LWP::UserAgent;
use URI::Escape;
use Getopt::Long;
use HTTP::Request::Common;

my %args;

GetOptions(
	'help'      => \$args{help},
	'smseagleurl=s' => \$args{smseagleurl},
	'apitoken=s'      => \$args{apitoken},
	'dstaddr=s' => \$args{dstaddr},
	'txt=s'     => \$args{txt}
	 );

if(defined($args{help}) || !defined($args{smseagleurl}) || !defined($args{apitoken}) || !defined($args{dstaddr}) || !defined($args{txt}) ) {
	print "Script usage: notify_eagle_sms.pl --smseagleurl <URL of your SMSEagle> --apitoken <API token for your SMSEagle> --dstaddr <phone number> --txt <message>
Example: notify_eagle_sms.pl --smseagleurl http://192.168.50.150 --apitoken jCOlMH8F2q --dstaddr 123456789 --txt \"My Message\"\n";
	exit(0);
}

## URL Encode the message text
my $text = uri_escape($args{txt});

## Build the URL
my $baseurl = $args{smseagleurl}.'/http_api/';
my $req = GET $baseurl."send_sms?access_token=$args{apitoken}&to=$args{dstaddr}&message=$text";


## Create the user agent and send the request
my $ua = LWP::UserAgent->new();
my $rsp = $ua->request($req);

## Process the response
if (index($rsp->content, "OK;") != -1) {
        print "Message sent succesfully to $args{dstaddr}\n";
} else {
        print "Message sending error: " . $rsp->content . "\n";
}
