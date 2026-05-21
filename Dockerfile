# 1. Bazujemy na oficjalnym obrazie scanservjs
FROM sbs20/scanservjs:latest

# 2. Przełączamy się na użytkownika root, aby mieć uprawnienia administracyjne
USER root

# 3. Definiujemy zmienne środowiskowe dla skanera sieciowego (można je nadpisać w docker-compose)
ENV BR_NAME="MojSkaner"
ENV BR_MODEL="DCP-T520W"
ENV BR_IP="192.168.1.100"

# 4. Aktualizujemy pakiety i instalujemy curl oraz biblioteki wymagane przez sterownik Brother
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libusb-0.1-4 \
    && rm -rf /var/lib/apt/lists/*

# 5. Pobieramy i instalujemy oficjalny sterownik Brother (brscan4)
#    (W przypadku nowszych modeli podmień link na brscan5)
RUN curl -L "https://download.brother.com/welcome/dlf006645/brscan4-0.4.11-1.amd64.deb" -o /tmp/brscan4.deb \
    && dpkg -i /tmp/brscan4.deb \
    && rm /tmp/brscan4.deb

# 6. Tworzymy niestandardowy skrypt startowy bezpośrednio w Dockerfile
#    Skrypt rejestruje skaner w systemie SANE za pomocą zmiennych IP i uruchamia aplikację
RUN echo '#!/bin/bash\n\
if [ -n "$BR_IP" ]; then\n\
  echo "Konfiguracja skanera sieciowego Brother: $BR_NAME ($BR_MODEL) pod adresem $BR_IP"\n\
  brsaneconfig4 -a name="$BR_NAME" model="$BR_MODEL" ip="$BR_IP"\n\
fi\n\
exec /docker-entrypoint.sh node server.js' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

# 7. Wskazujemy nasz skrypt jako punkt wejścia do kontenera
ENTRYPOINT ["/entrypoint.sh"]
