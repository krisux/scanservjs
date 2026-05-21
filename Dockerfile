# 1. Bazujemy na oficjalnym obrazie scanservjs
FROM sbs20/scanservjs:latest

# 2. Przełączamy się na użytkownika root
USER root

# 3. Definiujemy domyślne zmienne środowiskowe (nadpisujesz je w compose.yaml)
ENV BR_NAME="Skaner"
ENV BR_MODEL="DCP-1610W"
ENV BR_IP="10.44.44.19"

# 4. Aktualizujemy pakiety i instalujemy curl oraz biblioteki usb
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libusb-0.1-4 \
    && rm -rf /var/lib/apt/lists/*

# 5. Pobieramy i instalujemy sterownik Brother brscan4
RUN curl -L "https://download.brother.com/welcome/dlf105200/brscan4-0.4.11-1.amd64.deb" -o /tmp/brscan4.deb \
    && dpkg -i /tmp/brscan4.deb \
    && rm /tmp/brscan4.deb

ENTRYPOINT []

CMD ["/bin/bash", "-c", "brsaneconfig4 -r \"$BR_NAME\" 2>/dev/null; brsaneconfig4 -a name=\"$BR_NAME\" model=\"$BR_MODEL\" ip=\"$BR_IP\" && exec /docker-entrypoint.sh node server.js"]
