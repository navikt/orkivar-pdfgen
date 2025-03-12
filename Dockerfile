FROM ghcr.io/navikt/pdfgen

COPY templates /app/templates
COPY fonts /app/fonts
#COPY resources /app/resources