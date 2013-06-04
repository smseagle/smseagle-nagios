#!/usr/bin/perl
# 
# ============================== SUMMARY =====================================
#
# Summary : This plugin sends SMS alerts with SMSEagle hardware sms gateway
# Program : notify_eagle_sms.pl
# Version : 1.0
# Date : Feb 21 2013
# Author : Radoslaw Janowski / SMSEAGLE.EU 
# Forked from: Nagios-SMS-WT (https://github.com/m-r-h/Nagios-SMS-WT)
# License : BSD
# Copyright (c) 2013, SMSEagle www.smseagle.eu
#
# ============================= MORE INFO ======================================
#
# Visit: http://www.smseagle.eu
#
# The latest version of this plugin can be found on GitHub at:
# http://bitbucket.org/proximus/smseagle-nagios
#
# ============================= SETUP ==========================================
#
# Copy this file to your Nagios plugin folder
#
# SMSEAGLE SETUP
#
# Create a new user for this script in SMSEagle device.
# This user will be referenced below as: SMSEAGLEUSER and SMSEAGLEPASSWORD 
# Replace SMSEAGLEUSER and SMSEAGLEPASSWORD in script below with your values.
#
# NAGIOS SETUP
#
# 1. Create the SMS notification commands.  (Commonly found in commands.cfg)
#    Replace SMSEAGLEIP with IP Address of your SMSEagle device.
#    Replace SMSEAGLEUSER and SMSEAGLEPASSWORD with your user/password to SMSEagle.
#
# Define two commands:
# 
# 	define command { 
# 	        command_name notify-by-sms 
# 	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEIP -u SMSEAGLEUSER -p SMSEAGLEPASSWORD -d $CONTACTPAGER$ -t "NOTIFICATIONTYPE$ $SERVICESTATE$ $SERVICEDESC$ Host($HOSTNAME$) Info($SERVICEOUTPUT$) Date($SHORTDATETIME$)" 
# 	} 
#	
# 	define command { 
# 	        command_name host-notify-by-sms 
# 	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEIP -u SMSEAGLEUSER -p SMSEAGLEPASSWORD -d $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$ $HOSTSTATE$ Host($HOSTALIAS$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
# 	}
# 
# 
# 2. In your nagios contacts (Commonly found on contacts.cfg) add 
#     the contact. Field "pager" should contain a mobile number for sms alerts in
# 	full international format e.g. 48xxxxxxxxx
#    
# 
# 	define contact{
# 	        contact_name                    engineer
# 	        alias                           Support Engineer
# 	        service_notification_period     24x7
# 	        host_notification_period        24x7
# 	        service_notification_options    w,u,c,r
# 	        host_notification_options       d,u,r
# 	        service_notification_commands   notify-by-email,notify-by-sms
# 	        host_notification_commands      host-notify-by-email,host-notify-by-sms
# 	        email                           engineer@somedomain.com
# 	        pager                           48xxxxxxxx
# 	}
#
# 
# ============================= SCRIPT ==========================================
#
# Script params description:
#
# smseagleip = IP Address of your SMSEagle device (eg.: 192.168.1.150)
# user = SMSEagle user
# password = SMSEagle password
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
	'smseagleip=s' => \$args{smseagleip},
	'user=s'      => \$args{user},
	'password=s'     => \$args{password},
	'dstaddr=s' => \$args{dstaddr},
	'txt=s'     => \$args{txt}
	 );

if(defined($args{help}) || !defined($args{smseagleip}) || !defined($args{user}) || !defined($args{password}) || !defined($args{dstaddr}) || !defined($args{txt}) ) {
	print "usage: notify_eagle_sms.pl --smseagleip <ip of smsaegle> --user <username> --password <password> --dstaddr <destination number> --txt <message> \n";
	exit(0);
}

## URL Encode the message text
my $text = uri_escape($args{txt});

## Build the URL
my $baseurl = "http://".$args{smseagleip}.'/index.php/http_api/';
my $req = GET $baseurl."send_sms?login=$args{user}&pass=$args{password}&to=$args{dstaddr}&message=$text";


## Create the user agent and send the request
my $ua = LWP::UserAgent->new();
my $rsp = $ua->request($req);

## Process the response
if($rsp->content == "OK") {
	print "Message sent succesfully to $args{dstaddr}\n";
} else {
	print "Sent failure: " . $rsp->content . "\n";
}
