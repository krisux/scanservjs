# 1. Bazujemy na oficjalnym obrazie scanservjs
FROM sbs20/scanservjs:latest

# 2. Przełączamy się na użytkownika root, aby zainstalować sterowniki
USER root

# 3. Definiujemy zmienne środowiskowe z parametrami Twojego skanera
ENV BR_NAME="Skaner"
ENV BR_MODEL="DCP-1610W"
ENV BR_IP="10.44.44.19"

# 4. Instalujemy curl oraz biblioteki usb niezbędne dla sterowników Brothera
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libusb-0.1-4 \
    && rm -rf /var/lib/apt/lists/*

# 5. Pobieramy i instalujemy właściwy sterownik brscan4 ze sprawdzonego linku
RUN curl -L "https://download.brother.com/welcome/dlf105200/brscan4-0.4.11-1.amd64.deb" -o /tmp/brscan4.deb \
    && apt-get install -yq /tmp/brscan4.deb \
    && rm /tmp/brscan4.deb

# 6. Informujemy system SANE o istnieniu sterownika brscan4
RUN echo "brscan4" >> /etc/sane.d/dll.conf

# 7. Resetujemy domyślny ENTRYPOINT obrazu bazowego
ENTRYPOINT []

# 8. KOMENDA STARTOWA (Złoty środek):
#    Czyści stary wpis, dodaje Twój skaner za pomocą komendy, która u Ciebie 
#    zadziałała w 100%, a na koniec odpala ORYGINALNY skrypt startowy aplikacji.
CMD ["/bin/bash", "-c", "brsaneconfig4 -r \"$BR_NAME\" 2>/dev/null; brsaneconfig4 -a name=\"$BR_NAME\" model=\"$BR_MODEL\" ip=\"$BR_IP\" && exec /entrypoint.sh"]
