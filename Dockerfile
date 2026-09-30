FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Enable 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install desktop, XRDP, Wine and utilities
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        xrdp \
        xorg \
        xorgxrdp \
        xfce4 \
        xfce4-goodies \
        dbus-x11 \
        dbus \
        sudo \
        curl \
        wget \
        nano \
        net-tools \
        policykit-1 \
        pulseaudio \
        pulseaudio-utils \
        wine \
        wine32 \
        firefox-esr \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Root password
RUN echo "root:root" | chpasswd

# Xorg configuration
RUN mkdir -p /etc/X11 \
    && if [ -f /etc/X11/Xwrapper.config ]; then \
        sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config; \
       else \
        printf 'allowed_users=anybody\n' > /etc/X11/Xwrapper.config; \
       fi

# XFCE session
RUN printf '%s\n' \
    '#!/bin/sh' \
    'startxfce4' \
    > /root/.xsession \
    && chmod 700 /root/.xsession

# DBus machine ID
RUN mkdir -p /var/run/dbus \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && ln -sf /etc/machine-id /var/lib/dbus/machine-id

# XRDP configuration
RUN sed -i 's/^crypt_level=.*/crypt_level=low/' /etc/xrdp/xrdp.ini \
    && sed -i 's/^security_layer=.*/security_layer=rdp/' /etc/xrdp/xrdp.ini \
    && printf '%s\n' \
        '#!/bin/sh' \
        'unset DBUS_SESSION_BUS_ADDRESS' \
        'unset XDG_RUNTIME_DIR' \
        'startxfce4' \
       > /etc/xrdp/startwm.sh \
    && chmod +x /etc/xrdp/startwm.sh

# Add xrdp to SSL certificate group
RUN adduser xrdp ssl-cert

# Startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
