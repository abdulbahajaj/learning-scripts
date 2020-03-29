# Delete netns0 if it exists
sudo ip netns delete netns0

# Setting up the namespace
sudo ip netns add netns0
echo "Added netns"

sudo ip link add veth-default type veth peer name veth-netns0
echo "Added veth network interfaces"

sudo ip link set veth-netns0 netns netns0
echo "Moved one of the Veth pairs to the NETNS"

# Bringing interfaces up
sudo ip link set veth-default up
sudo ip netns exec netns0 ip link set veth-netns0 up
echo "Brought the interfaces up"

# Adding routing table
sudo ip addr add 172.0.0.1/16 dev veth-default
sudo ip netns exec netns0 ip addr add 172.0.0.2/16 dev veth-netns0
sudo ip netns exec netns0 ip route add default via 172.0.0.1
echo "Added routing rules"

Enable packet forwarding
sudo sysctl net.ipv4.ip_forward=1
echo "Enabled port forwarding"

# Forward packet between veth-default and the exposed port
sudo iptables -A FORWARD -o eth0 -i veth-default -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o veth-default -j ACCEPT
echo "Set up iptable forwarding rules"

# Setting up  of masquerading IPs generated from the netns and heading to the internet
sudo iptables -t nat -A POSTROUTING -s 172.0.0.2 -o eth0 -j MASQUERADE
echo "Set up masquerading"
