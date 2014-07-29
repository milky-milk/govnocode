#!/bin/bash

IPTABLES=/sbin/iptables
IPTABLESSAVE=/sbin/iptables-save
IPTABLESRESTORE=/sbin/iptables-restore
FIREWALL=/etc/sysconfig/iptables

#inside
EXT_IP=
EXT_IF=eth0
INT_IP=192.168.1.1
INT_IF=eth1
LOCAL_NETWORK=192.168.1.0/24


opts="${opts} showstatus panic save restore showoptions rules"

rules() {
	echo "Setting firewall rules"

	echo "Flushing any old rules"
	$IPTABLES -F
	$IPTABLES -t nat -F
	$IPTABLES -X

	echo "Setting default rule to drop"
	$IPTABLES -P FORWARD DROP
	$IPTABLES -P INPUT DROP
	$IPTABLES -P OUTPUT DROP

	#------------------------------------------------------------------------------------
	echo "Creating Connection-Tracking rule"
	$IPTABLES -N state-tracking
	$IPTABLES -F state-tracking
	$IPTABLES -A state-tracking -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPTABLES -A state-tracking -m state --state INVALID -j DROP

	#Catch portscanners
	echo "Creating portscan detection rule"
	$IPTABLES -N portscan
	$IPTABLES -F portscan
	$IPTABLES -A portscan -p tcp --tcp-flags ALL FIN,URG,PSH -m limit --limit 5/minute -j LOG --log-level alert --log-prefix "PORTSCAN (NMAP-XMAS): "
	$IPTABLES -A portscan -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
	$IPTABLES -A portscan -p tcp --tcp-flags ALL ALL -m limit --limit 5/minute -j LOG --log-level 1 --log-prefix "PORTSCAN (XMAS): "
	$IPTABLES -A portscan -p tcp --tcp-flags ALL ALL -j DROP
	$IPTABLES -A portscan -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m limit --limit 5/minute -j LOG --log-level 1 --log-prefix "PORTSCAN (XMAS-PSH): "
	$IPTABLES -A portscan -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
	$IPTABLES -A portscan -p tcp --tcp-flags ALL NONE -m limit --limit 5/minute -j LOG --log-level 1 --log-prefix "PORTSCAN (NULL_SCAN): "
	$IPTABLES -A portscan -p tcp --tcp-flags ALL NONE -j DROP
	$IPTABLES -A portscan -p tcp --tcp-flags SYN,RST SYN,RST -m limit --limit 5/minute -j LOG --log-level 5 --log-prefix "PORTSCAN (SYN/RST): "
	$IPTABLES -A portscan -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
	$IPTABLES -A portscan -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/minute -j LOG --log-level 5 --log-prefix "PORTSCAN (SYN/FIN): "
	$IPTABLES -A portscan -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
	#------------------------------------------------------------------------------------

	#------------------------------------------------------------------------------------
	#Incoming connection rules
	echo "Creating incoming connection rules"
	$IPTABLES -N incoming_con
	$IPTABLES -F incoming_con

	#ICMP Rules
	$IPTABLES -A incoming_con -m state --state NEW -p icmp --icmp-type time-exceeded -j ACCEPT
	$IPTABLES -A incoming_con -m state --state NEW -p icmp --icmp-type destination-unreachable -j ACCEPT
	$IPTABLES -A incoming_con -p icmp -j LOG --log-prefix "[Bad ICMP]: "
	$IPTABLES -A incoming_con -p icmp -j DROP

	#Allow SSH with Flood protection
	$IPTABLES -A incoming_con -p tcp --dport 22 -j LOG --log-prefix "[Incoming SSH]: "
	$IPTABLES -A incoming_con -m limit --limit 1/second -p tcp --tcp-flags ALL RST --dport 22 -j ACCEPT
	$IPTABLES -A incoming_con -m limit --limit 1/second -p tcp --tcp-flags ALL FIN --dport 22 -j ACCEPT
	$IPTABLES -A incoming_con -m limit --limit 1/second -p tcp --tcp-flags ALL SYN --dport 22 -j ACCEPT

	#Allow DNS Connections
	$IPTABLES -A incoming_con -p tcp --dport 53 -j ACCEPT
	$IPTABLES -A incoming_con -p udp --dport 53 -j ACCEPT
    $IPTABLES -A incoming_con -p tcp --sport 53 -j ACCEPT
    $IPTABLES -A incoming_con -p udp --sport 53 -j ACCEPT


	#Allow WEB Connetions
	$IPTABLES -A incoming_con -p tcp --dport 80 -j ACCEPT
	$IPTABLES -A incoming_con -p tcp --dport 443 -j ACCEPT
	
	
	#Allow JABBER Connetions
	#	$IPTABLES -A incoming_con -p tcp --dport 5222 -j ACCEPT
	#	$IPTABLES -A incoming_con -p tcp --dport 5223 -j ACCEPT

	echo "Allowing incoming ICMP SSH DNS WEB JABBER"
	#------------------------------------------------------------------------------------

	#------------------------------------------------------------------------------------
	#Outgoing connection rules
	echo "Creating outgoing connection rules"

	$IPTABLES -N outgoing_con
	$IPTABLES -F outgoing_con

    #ICMP Rules
	$IPTABLES -A outgoing_con -m state --state NEW -p icmp --icmp-type time-exceeded -j ACCEPT
	$IPTABLES -A outgoing_con -m state --state NEW -p icmp --icmp-type destination-unreachable -j ACCEPT
	$IPTABLES -A outgoing_con -p icmp -j LOG --log-prefix "[Bad ICMP]: "
	$IPTABLES -A outgoing_con -p icmp -j DROP

	#Allow SSH
	$IPTABLES -A outgoing_con -p tcp --sport 22 -j ACCEPT

    #Allow DNS Connections
    $IPTABLES -A outgoing_con -p tcp --sport 53 -j ACCEPT
    $IPTABLES -A outgoing_con -p udp --sport 53 -j ACCEPT
    $IPTABLES -A outgoing_con -p tcp --dport 53 -j ACCEPT
    $IPTABLES -A outgoing_con -p udp --dport 53 -j ACCEPT


    #Allow WEB Connetions
    $IPTABLES -A outgoing_con -p tcp --sport 80 -j ACCEPT
    $IPTABLES -A outgoing_con -p tcp --sport 443 -j ACCEPT

#Allow JABBER Connetions
#$IPTABLES -A outgoing_con -p tcp --sport 5222 -j ACCEPT
#$IPTABLES -A outgoing_con -p tcp --sport 5223 -j ACCEPT
	
	echo "Allowing outgoing ICMP SSH DNS WEB JABBER"
	#------------------------------------------------------------------------------------

	#------------------------------------------------------------------------------------
	# Apply and add invalid states to the chains
	echo "Applying rules to INPUT"
	$IPTABLES -A INPUT -j state-tracking
	$IPTABLES -A INPUT -j portscan
	$IPTABLES -A INPUT -i lo -j ACCEPT
	$IPTABLES -A INPUT -i $INT_IF -j ACCEPT  #Allow local traffic
	$IPTABLES -A INPUT -j incoming_con
	$IPTABLES -A INPUT -j LOG --log-prefix "[Dropped Incoming con] "
	$IPTABLES -A INPUT -j DROP


	echo "Applying rules to FORWARD"
	$IPTABLES -A FORWARD -j state-tracking
	$IPTABLES -A FORWARD -j portscan
	$IPTABLES -A FORWARD -o lo -j ACCEPT
	$IPTABLES -A FORWARD -i $INT_IF -s $LOCAL_NETWORK -j ACCEPT
	$IPTABLES -A FORWARD -o $INT_IF -d $LOCAL_NETWORK -j ACCEPT
	$IPTABLES -A FORWARD -j incoming_con
	$IPTABLES -A FORWARD -j DROP

	echo "Applying rules to OUTPUT"
	$IPTABLES -A OUTPUT -j state-tracking
	$IPTABLES -A OUTPUT -o lo -j ACCEPT
	$IPTABLES -A OUTPUT -o $INT_IF -j ACCEPT  #Allow local traffic
	$IPTABLES -A OUTPUT -j outgoing_con
	$IPTABLES -A OUTPUT -j DROP

	#echo "Enable Masqerading"
	#$IPTABLES -t nat -A POSTROUTING -s 192.168.1.29 -o eth1 -j MASQUERADE
}

start() {
	echo "Starting firewall"
	rules
}

stop() {
	echo "Stopping firewall"
	$IPTABLES -F
	$IPTABLES -t nat -F
	$IPTABLES -X
	$IPTABLES -P FORWARD ACCEPT
	$IPTABLES -P INPUT ACCEPT
	$IPTABLES -P OUTPUT ACCEPT
}

showstatus() {
	echo "Status"
	$IPTABLES -L -n -v --line-numbers
}

panic() {
	echo "Setting panic rules"
	$IPTABLES -F
	$IPTABLES -X
	$IPTABLES -t nat -F
	$IPTABLES -P FORWARD DROP
	$IPTABLES -P INPUT DROP
	$IPTABLES -P OUTPUT DROP
	$IPTABLES -A INPUT -i lo -j ACCEPT
	$IPTABLES -A OUTPUT -o lo -j ACCEPT
}

save() {
	echo "Saving Firewall rules"
	$IPTABLESSAVE > $FIREWALL
}

restore() {
	echo "Restoring Firewall rules"
	$IPTABLESRESTORE < $FIREWALL
}

restart() {
	stop
    start
}

showoptions() {
	echo "Usage: $0 {start|save|restore|panic|stop|restart|showstatus} "
	echo "start) will restore setting if exists else force rules"
	echo "stop) delete all rules and set all to accept"
	echo "restart) restart rules"
	echo "panic) set all rules to DROP"
	echo "save) will store settings in ${FIREWALL}"
	echo "restore) will restore settings from ${FIREWALL}"
	echo "showstatus) Shows the status"
}

case "$1" in
    start)
	    stop
 	 	start
	    ;;
    stop)
	    stop
	    ;;
    restart)
	    restart
	    ;;
    showstatus)
	    showstatus
	    ;;
    panic)
		panic
        ;;
    save)
	    save
	    ;;
	restore)
		restore
		;;
    *)
		showoptions
	    exit 1
	    ;;
esac

