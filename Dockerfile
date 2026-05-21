# 1. Bazujemy na oficjalnym obrazie scanservjs
FROM sbs20/scanservjs:latest

# 2. Przełączamy się na użytkownika root
USER root

# 3. Definiujemy zmienne środowiskowe dla skanera sieciowego
ENV BR_NAME="MojSkaner"
ENV BR_MODEL="DCP-1610W"
ENV BR_IP="10.44.44.19"

# 4. Aktualizujemy pakiety i instalujemy curl oraz wymagane biblioteki
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libusb-0.1-4 \
    && rm -rf /var/lib/apt/lists/*

# 5. Pobieramy i instalujemy sterownik Brother brscan4
RUN curl -L "https://download.brother.com/welcome/dlf006645/brscan4-0.4.11-1.amd64.deb" -o /tmp/brscan4.deb \
    && dpkg -i /tmp/brscan4.deb \
    && rm /tmp/brscan4.deb

# 6. POPRAWIONY SKRYPT: Odpalamy konfigurację Brothera, a potem bezpośrednio 
#    właściwą aplikację w jej domyślnym katalogu roboczym (/app)
RUN echo '#!/bin/bash\n\
if [ -n "$BR_IP" ]; then\n\
  echo "Konfiguracja skanera sieciowego Brother: $BR_NAME ($BR_MODEL) pod adresem $BR_IP"\n\
  # Usuwamy starą rejestrację na wypadek restartu kontenera, żeby uniknąć błędów\n\
  brsaneconfig4 -r "$BR_NAME" 2>/dev/null\n\
  brsaneconfig4 -a name="$BR_NAME" model="$BR_MODEL" ip="$BR_IP"\n\
fi\n\
cd /app\n\
exec node server.js' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

# 7. Punkt wejścia
ENTRYPOINT ["/entrypoint.sh"]
