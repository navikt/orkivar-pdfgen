FROM ghcr.io/navikt/pdfgen:latest

COPY templates /app/templates
COPY fonts /app/fonts
#COPY resources /app/resources