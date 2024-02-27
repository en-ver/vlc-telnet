# vlc-telnet

**Short Description:** A Docker image of VLC with a Telnet interface for remote control, ideal for use with Home Assistant's VLC Telnet integration.

## Overview

This image enables remote management of a VLC media player instance through Telnet. Key features and considerations:

* **Telnet Password:** Customizable via the `VLC_TELNET_PASSWORD` environment variable in your docker-compose file.
* **USB Sound Speakers:** Designed specifically for use with USB sound speakers.
* **Device Selection:** If multiple USB speakers are present, the behavior is undefined.  It's recommended to use only one USB speaker with this image.
* **Privileged Mode:** Requires privileged mode for access to USB audio devices. 

## How to Use

**Docker Run:**

```bash
docker run -d --privileged -p 4212:4212 -e VLC_TELNET_PASSWORD=your_strong_password \
    ne1ver/vlc-telnet
```
**Docker Compose (sample):**
```yaml
version: '3.3' 
services:
  vlc-app:
    image: ne1ver/vlc-telnet
    ports:
      - "4212:4212"
    devices:
      - "/dev/snd:/dev/snd"
    environment:
      - VLC_TELNET_PASSWORD=your_strong_password 
    restart: unless-stopped 
```
## Additional Notes
This image is built for multiple architectures for broader compatibility.
For production environments, consider using a secrets management solution for handling the Telnet password.
**Disclaimer**
This image is provided as-is, and I offer no guarantee of its suitability for any specific purpose.

Project Link: https://github.com/en-ver/vlc-telnet
