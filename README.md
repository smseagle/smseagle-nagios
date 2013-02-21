Nagios-SMS-EAGLE
================

Plugin for Nagios to send SMS Text Message notifications with SMSEagle device
Forked from Nagios-SMS-WT (https://github.com/m-r-h/Nagios-SMS-WT)

Published on BSD License


SMSEAGLE SETUP

Create a new user for this script in SMSEagle.
This user will be referenced below as: SMSEAGLEUSER and SMSEAGLEPASSWORD 
Replace SMSEAGLEUSER and SMSEAGLEPASSWORD in script below with your values.



NAGIOS SETUP

1. Create the SMS notification commands.  (Commonly found in commands.cfg)
    Replace SMSEAGLEIP with IP Address of your SMSEagle device.
    Replace SMSEAGLEUSER and SMSEAGLEPASSWORD with your user/password to SMSEagle.

Define two commands:

	define command { 
	        command_name notify-by-sms 
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEIP -u SMSEAGLEUSER -p SMSEAGLEPASSWORD -d $CONTACTPAGER$ -t "NOTIFICATIONTYPE$ $SERVICESTATE$ $SERVICEDESC$ Host($HOSTNAME$) Info($SERVICEOUTPUT$) Date($SHORTDATETIME$)" 
	} 
	
	define command { 
	        command_name host-notify-by-sms 
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEIP -u SMSEAGLEUSER -p SMSEAGLEPASSWORD -d $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$ $HOSTSTATE$ Host($HOSTALIAS$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
	}


2. In your nagios contacts (Commonly found on contacts.cfg) add 
    the contact. Field "pager" should contain a mobile number for sms alerts in
    full international format e.g. 48xxxxxxxxx
    
	define contact {
	        contact_name                    engineer
	        alias                           Support Engineer
	        service_notification_period     24x7
	        host_notification_period        24x7
	        service_notification_options    w,u,c,r
	        host_notification_options       d,u,r
	        service_notification_commands   notify-by-email,notify-by-sms
	        host_notification_commands      host-notify-by-email,host-notify-by-sms
	        email                           engineer@somedomain.com
	        pager                           48xxxxxxxx
	}
