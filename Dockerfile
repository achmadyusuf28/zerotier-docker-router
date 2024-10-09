# Use Debian Bookworm as a base image
FROM debian:bookworm-slim

# Set environment variables (optional)
ENV ZT_HOME /var/lib/zerotier-one

# Update package index and install required packages
RUN apt-get update && \
    apt-get install -y curl gnupg iproute2 iptables && \
    curl -s https://install.zerotier.com/ | bash && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Expose port 9993 (default for ZeroTier management)
EXPOSE 9993/udp

# Create a startup script to handle joining the network and persistent data
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use as entry point the script to join the zerotier network on start
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]