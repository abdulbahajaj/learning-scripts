export NAMESPACE=netns0;
export NSVETH=veth-$NAMESPACE;
export DEFVETH=veth-def$NAMESPACE;
export NSIP=172.0.0.2
export DEFIP=172.0.0.1

# Delete namespace if it exists
sudo ip netns delete $NAMESPACE

# Setting up the namespace
sudo ip netns add $NAMESPACE
echo "Added netns"

sudo ip link add $DEFVETH type veth peer name $NSVETH
echo "Added veth network interfaces"

sudo ip link set $NSVETH netns $NAMESPACE
echo "Moved one of the Veth pairs to the NETNS"

# Bringing interfaces up
sudo ip link set $DEFVETH up
sudo ip netns exec $NAMESPACE ip link set $NSVETH up
echo "Brought the interfaces up"

# Adding routing table
sudo ip addr add $DEFIP/16 dev $DEFVETH
sudo ip netns exec $NAMESPACE ip addr add $NSIP/16 dev $NSVETH
sudo ip netns exec $NAMESPACE ip route add default via $DEFIP
echo "Added routing rules"

# Enable packet forwarding
sudo sysctl net.ipv4.ip_forward=1
echo "Enabled ip forwarding"

# Forward packet between veth-default and the exposed port
sudo iptables -A FORWARD -o eth0 -i $DEFVETH -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o $DEFVETH -j ACCEPT
echo "Set up iptable forwarding rules"

# exit 1
# Setting up  of masquerading IPs generated from the netns and heading to the internet
sudo iptables -t nat -A POSTROUTING -s $NSIP -o eth0 -j MASQUERADE
echo "Set up masquerading"
