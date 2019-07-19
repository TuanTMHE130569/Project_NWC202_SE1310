#-------Event scheduler object creation--------#
       
set ns [ new Simulator]
# ----------- CREATING NAM OBJECTS -----------------#
set nf [open ns2.nam w]
$ns namtrace-all $nf
#Open the trace file
set nt [open ns2.tr w]
$ns trace-all $nt

set proto rlm
$ns color 1 red
$ns color 2 green
$ns color 3 blue
$ns color 4 yellow

# --------- CREATING CLIENT - ROUTER -SERVER NODES-----------#
set Client1 [$ns node]
set Client2 [$ns node]
set Client3 [$ns node]
set Client4 [$ns node]
set Router [$ns node]
set Server [$ns node]
# --------------CREATING DUPLEX LINK -----------------------#
                        
$ns duplex-link $Client1 $Router 5Mb 50ms DropTail
$ns duplex-link $Client2 $Router 5Mb 50ms DropTail
$ns duplex-link $Client3 $Router 5Mb 50ms DropTail
$ns duplex-link $Client4 $Router 5Mb 50ms DropTail
$ns duplex-link $Router $Server 300Kb 50ms DropTail

 #-----------CREATING ORIENTATION -------------------------#
                  
$ns duplex-link-op $Client1 $Router orient down-right
$ns duplex-link-op $Client2 $Router orient right 
$ns duplex-link-op $Client3 $Router orient up-right 
$ns duplex-link-op $Client4 $Router orient up
$ns duplex-link-op $Router $Server orient right

 # --------------CREATING LABELLING -----------------------------#
$ns at 0.0 "$Client1 label Client1"
$ns at 0.0 "$Client2 label Client2"
$ns at 0.0 "$Client3 label Client3"
$ns at 0.0 "$Client4 label Client4"
$ns at 0.0 "$Router label Router"
$ns at 0.0 "$Server label Server"

# --------------- CONFIGURING NODES -----------------#
$Server shape hexagon
$Router shape box
# ----------------ESTABLISHING QUEUES -------------#
$ns duplex-link-op $Client1 $Router queuePos 0.1
$ns duplex-link-op $Client2 $Router queuePos 0.1
$ns duplex-link-op $Client3 $Router queuePos 0.5
$ns duplex-link-op $Client4 $Router queuePos 0.5
$ns duplex-link-op $Router $Server queuePos 0.5
# ----------------ESTABLISHING COMMUNICATION -------------# 
            
#-------CLIENT1 TO Server -------------#
set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 16
$tcp1 set fid_ 1
$ns attach-agent $Client1 $tcp1
set sink0 [new Agent/TCPSink]
$ns attach-agent $Server $sink0
$ns connect $tcp1 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp1
$ns add-agent-trace $tcp1 tcp
$tcp1 tracevar cwnd_
$ns at 0.5 "$ftp0 start"
$ns at 28.5 "$ftp0 stop"
# ---------------- CLIENT2 TO Server -------------#
set tcp2 [new Agent/TCP]
$tcp2 set fid_ 2
$tcp2 set maxcwnd_ 16
$ns attach-agent $Client2 $tcp2
set sink1 [new Agent/TCPSink]
$ns attach-agent $Server $sink1
$ns connect $tcp2 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp2
$ns add-agent-trace $tcp2 tcp1
$tcp2 tracevar cwnd_
$ns at 0.58 "$ftp1 start"
$ns at 28.5 "$ftp1 stop"
# ----------------CLIENT3 TO Server------------#
 set tcp3 [new Agent/TCP]
$tcp3 set fid_ 3
$tcp3 set maxcwnd_ 16
$tcp3 set packetsize_ 100
$ns attach-agent $Client3 $tcp3
set sink2 [new Agent/TCPSink]
$ns attach-agent $Server $sink2
$ns connect $tcp3 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp3
$ns add-agent-trace $tcp3 tcp2
$tcp3 tracevar cwnd_
$ns at 0.65 "$ftp2 start"
$ns at 28.5 "$ftp2 stop"
 #--------------------CLIENT4 TO Server----------------#
set tcp4 [new Agent/TCP]
$tcp4 set fid_ 4
$tcp4 set maxcwnd_ 16
$tcp4 set packetsize_ 100
$ns attach-agent $Client4 $tcp4
set sink3 [new Agent/TCPSink]
$ns attach-agent $Server $sink3
$ns connect $tcp4 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp4
$ns add-agent-trace $tcp4 tcp3
$tcp4 tracevar cwnd_
$ns at 0.60 "$ftp3 start"
$ns at 28.5 "$ftp3 stop"
#define procedure to plot the congestion window
proc xgACK {tcpSource outfile} {
   	global ns
   	set now [$ns now]
   	set tracevar [$tcpSource set ack_]
	#set tracevar [$tcpSource1 set cwnd_]
	# the data is recorded in a xg file
   	puts  $outfile  "$now $tracevar"
   	$ns at [expr $now+0.1] "xgACK $tcpSource $outfile"
}

set outfile [open  "graph.xg"  w]
$ns  at  0.0  "xgACK $tcp1 $outfile"

# ---------------- FINISH PROCEDURE -------------#              
proc finish {} {
            
                  
               global ns nf nt 
               
               $ns flush-trace
               close $nf
               puts "running nam..."           
               #exec nam ns2.nam &
		#exec xgraph graph.xg -geometry 800x400 &		
               exit 0
            }
#Calling finish procedure
$ns at 15.0 "finish"
$ns run
