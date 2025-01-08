Nagios-SMS-EAGLE
================

Plugin for Nagios to send SMS Text Message notifications with SMSEagle device (www.smseagle.eu)


Project location: https://bitbucket.org/proximus/smseagle-nagios

Forked from Nagios-SMS-WT (https://github.com/m-r-h/Nagios-SMS-WT)

Published on BSD License

Setup is extremally easy - it should take 5-10min.


#### SMSEAGLE SETUP

1. Create a new user for this script in SMSEagle webGUI > menu Users.
2. When the user is saved, edit its permissions by clicking "Access to API" and under "API Access token":\
a) check "Enable token"\
b) click "Generate new token"\

This will generate a new API access token for your SMSEagle. This API token will be referenced below as **SMSEAGLEAPITOKEN**. Replace **SMSEAGLEAPITOKEN** in script below with your value.
3. In the same menu, add the permissions for methods you want to use:
   - send_sms => sms
   - ring_call => ring
   - tts_call => tts
   - tts_adv_call => tts_adv



#### NAGIOS SETUP

1. Create the SMS notification commands.  (Commonly found in commands.cfg)
2. Replace **SMSEAGLEURL** with URL Address of your SMSEagle device (for example: http://192.168.50.150)
3. Replace **SMSEAGLEAPITOKEN** with your API token for your SMSEagle (for example: NZg2yNmWYb5Q7I3Y3Ifnk5E)\
(Optional parameter for calls, default: 10) Add **-duration** parameter with call duration value (in seconds, e.g. -duration 15)\
(Required for TTS Advanced) Replace **SMSEAGLEVOICE** with voice model ID (found in SMSEagle menu, Calls > TTS Voice models)

Define two commands:

	define command {
	        command_name notify-by-sms 
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -dstaddr $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$ $SERVICESTATE$ $SERVICEDESC$ Host($HOSTNAME$) Info($SERVICEOUTPUT$) Date($SHORTDATETIME$)" 
	} 
	
	define command { 
	        command_name host-notify-by-sms 
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -dstaddr $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$ $HOSTSTATE$ Host($HOSTALIAS$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
	}

	define command { 
	        command_name notify-by-ring-call 
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -c ring -dstaddr $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$ $SERVICESTATE$ $SERVICEDESC$ Host($HOSTNAME$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
	}

	define command { 
	        command_name host-notify-by-ring-call 
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -c ring -dstaddr $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$ $HOSTSTATE$ Host($HOSTALIAS$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
	}

	define command { 
	        command_name notify-by-tts-call 
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -c tts -dstaddr $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$ $SERVICESTATE$ $SERVICEDESC$ Host($HOSTALIAS$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
	}

	define command { 
	        command_name host-notify-by-tts-call 
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -c tts -dstaddr $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$ $HOSTSTATE$ Host($HOSTALIAS$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
	}

	define command { 
	        command_name notify-by-tts-adv-call
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -c tts_adv -dstaddr $CONTACTPAGER$ -voiceid SMSEAGLEVOICE -t "$NOTIFICATIONTYPE$ $SERVICESTATE$ $SERVICEDESC$ Host($HOSTALIAS$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
	}

	define command { 
	        command_name host-notify-by-tts-adv-call
	        command_line $USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -c tts_adv -dstaddr $CONTACTPAGER$ -voiceid SMSEAGLEVOICE -t "$NOTIFICATIONTYPE$ $HOSTSTATE$ Host($HOSTALIAS$) Info($HOSTOUTPUT$) Time($SHORTDATETIME$)" 
	}


4. In your nagios contacts (Commonly found on contacts.cfg) add the contact.\
   Field "pager" should contain a mobile number for sms alerts in full international format e.g. 48xxxxxxxxx


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


#### ADDITIONAL COMMENTS
If you would like to use a newline character in your text message use the following string for a newline: "$'\n'"  
For example:\
$USER1$/notify_eagle_sms.pl -s SMSEAGLEURL -a SMSEAGLEAPITOKEN -d $CONTACTPAGER$ -t "$NOTIFICATIONTYPE$"$'\n'"$HOSTSTATE$"$'\n'"Host($HOSTALIAS$)"$'\n'"Info($HOSTOUTPUT$)"$'\n'"Time($SHORTDATETIME$)"
