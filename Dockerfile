FROM debian:stable-slim

# Install ALSA utilities and VLC
RUN apt-get update && apt-get install -y --no-install-recommends \
    alsa-utils vlc \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port 4212 for VLC's management interface
EXPOSE 4212

# Create entrypoint script 
COPY entrypoint.sh /entrypoint.sh

# Set executable permissions on the entrypoint script
RUN chmod +x /entrypoint.sh 

# Create vlc user 
RUN useradd -ms /bin/false vlc
RUN usermod -aG audio vlc

# Switch to the 'vlc' user for running the process
USER vlc

# Set the entrypoint to execute the script 
ENTRYPOINT ["/entrypoint.sh"]
