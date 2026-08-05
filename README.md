## PDF-generering for aktivtetsplanen og dialogen
Bruker https://github.com/navikt/pdfgenrs

## Test lokalt

1. Start colima/docker deamon 😈
2. ``./run_dev.sh`` (Kjører appen lokalt med docker med noen hard-kodede args)
3. Gå til: `http://localhost:8080/api/v1/genpdf/dab/aktivitetsplan`  (url + folderName + templateName)
