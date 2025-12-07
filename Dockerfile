FROM debian:stable-slim

# Install VLC and ALSA with proper cleanup and user creation
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        alsa-utils \
        vlc && \
    # Create non-root user with proper audio permissions
    groupadd -r vlc && \
    useradd -r -g vlc vlc && \
    usermod -aG audio vlc && \
    # Aggressive cleanup for minimal size
    apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/*

# Copy entrypoint script with proper permissions
COPY --chmod=755 --chown=vlc:vlc entrypoint.sh /entrypoint.sh

# Expose port 4212 for VLC's management interface
EXPOSE 4212

# Switch to the 'vlc' user for running the process
USER vlc

# Set the entrypoint to execute the script
ENTRYPOINT ["/entrypoint.sh"]
