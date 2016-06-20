#!/bin/bash
#-------------------------------------------------------
# file:         compila.sh
# version:      1.0
# comment:      Gera a apostila no formato PDF a partir da compilacao dos arquivos fontes
# author:       Miguel Di Ciurcio Filho <miguel@instruct.com.br>
# revision:     Aecio Pires <aeciopires@gmail.com>
# Last updated: 20-jun-2016, 13:48
#-------------------------------------------------------

which libreoffice &> /dev/null

if [ $? -ne 0 ]; then
  echo '[ERRO] Nao encontrei o LibreOffice.'
  exit 1
fi

which rst2pdf &> /dev/null

if [ $? -ne 0 ]; then
  echo '[ERRO] Nao encontrei o pacote rst2pdf.'
  exit 1
fi

#Convertendo a capa de ODT para PDF
#libreoffice --headless --invisible --convert-to pdf capa.odt
libreoffice swriter --convert-to pdf capa.odt --headless --invisible

#Gerando a apostila no formato PDF a partir dos arquivos fontes
rst2pdf --custom-cover cover.tmpl -b 1 -s manual.style -l pt_br index.rst -o apostila-puppet.pdf
