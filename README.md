# lifx-bash

You can use the output of setcolor.sh script in combination with
SoCAT to sent an UDP datagram to LIFX bulbs. This is the way:

```bash
for x in $(seq 1 1000 10000); do                 
    echo -e $(./setcolor.sh 10000 0 0xffff $x 100) | socat -u - udp-datagram:192.168.0.255:56700,broadcast
    sleep 1
done
```

You can monitor LIFX packets with tcpdump:

```
tcpdump -n udp port 57600
```

or with SoCAT using the helper script headerdump.sh: 

```
socat -u udp4-recvfrom:56700,reuseaddr,fork system:'./headerdump.sh'
```

This work is based on two posts of the LIFX community site: 

* https://community.lifx.com/t/building-a-lifx-packet/59
* https://community.lifx.com/t/controlling-lights-with-bash/31
 
