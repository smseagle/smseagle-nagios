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
# content = Content type of the message/call to send (possible values: sms, ring, tts, tts_adv; default: sms)
# dstaddr = Destination mobile number (the number to send message/make a call to)
# txt = The text message body (required for SMS, TTS and TTS Advanced)
# duration = Duration of the call (Ring, TTS and TTS Advanced only, default: 10)
# voiceid = ID of the voice model (required for TTS Advanced)

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
	'content=s'    => \$args{content},
	'dstaddr=s' => \$args{dstaddr},
	'txt=s'     => \$args{txt},
	'duration=s'     => \$args{duration},
	'voiceid=s'     => \$args{voiceid},
);

my $content;
if (!defined($args{content})) {
    $content = 'sms';
} else {
    $content = $args{content};
}

my $duration;
if (!defined($args{duration})) {
    $duration = '10';
} else {
    $duration = $args{duration};
}

if(defined($args{help}) || !defined($args{smseagleurl}) || !defined($args{apitoken}) || !defined($args{dstaddr}))
{
	print "Script usage: notify_eagle_sms.pl --smseagleurl <URL of your SMSEagle> --apitoken <API token for your SMSEagle> --content <Message content type (possible values: sms, ring, tts, tts_adv)> --dstaddr <Phone number> --txt <Message> --duration <Call duration> --voiceid <Voice model ID>
Example: notify_eagle_sms.pl --smseagleurl http://192.168.50.150 --apitoken jCOlMH8F2q --content sms --dstaddr 123456789 --txt \"My Message\"\n";
	exit(0);
}

if ($content eq 'sms' && !defined($args{txt})) {
    print('Missing required parameters (txt)');
    exit(0);
}

if ($content eq 'tts' && !defined($args{txt})) {
    print('Missing required parameters (txt)');
    exit(0);
}

if ($content eq 'tts_adv' && (!defined($args{txt}) || !defined($args{voiceid}))) {
    print('Missing required parameters (txt, voiceid)');
    exit(0);
}

## URL Encode the message text
my $text = uri_escape($args{txt});

## Build the URL
my $method = "send_sms";

if ($content eq 'ring') {
    $method = "ring_call";
}
if ($content eq 'tts') {
    $method = "tts_call";
}
if ($content eq 'tts_adv') {
    $method = "tts_adv_call";
}

my $baseurl = $args{smseagleurl}.'/http_api/'.$method;
my $params = '?access_token='.$args{apitoken}.'&to='.$args{dstaddr};

if ($content eq 'sms' || $content eq 'tts' || $content eq 'tts_adv') {
    $params = $params."&message=".$text;
}

if ($content eq 'ring' || $content eq 'tts' || $content eq 'tts_adv') {
    $params = $params."&duration=".$duration;
}

if ($content eq 'tts_adv') {
    $params = $params."&voice_id=".$args{voiceid};
}

$baseurl = $baseurl.$params;

my $req = GET $baseurl;

## Create the user agent and send the request
my $ua = LWP::UserAgent->new();
my $rsp = $ua->request($req);

## Process the response
if (index($rsp->content, "OK;") != -1) {
        print "Message sent succesfully to $args{dstaddr}\n";
} else {
        print "Message sending error: " . $rsp->content . "\n";
}
