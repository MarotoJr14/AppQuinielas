#!/bin/bash

set -e

echo "======================================"
echo "   BUILD RELEASE - APP QUINIELAS"
echo "   iOS"
echo "======================================"
echo

# --------------------------------------
# Obtener version desde pubspec.yaml
# --------------------------------------
VERSION_LINE=$(grep '^version:' pubspec.yaml | awk '{print $2}')
VERSION=${VERSION_LINE%%+*}

echo "Version: $VERSION"
echo

# --------------------------------------
# Limpiar proyecto y obtener dependencias
# --------------------------------------
echo "--------------------------------------"
echo "Limpiando proyecto..."
echo "--------------------------------------"

flutter clean
flutter pub get

# --------------------------------------
# Construir IPA
# --------------------------------------
echo
echo "--------------------------------------"
echo "Construyendo iOS..."
echo "--------------------------------------"

flutter build ipa --release

# --------------------------------------
# Buscar IPA generado
# --------------------------------------
IPA_ORIGINAL=$(find build/ios/ipa -maxdepth 1 -name "*.ipa" -type f | head -n 1)

if [ -z "$IPA_ORIGINAL" ]; then
    echo
    echo "ERROR: No se ha encontrado el IPA generado."
    exit 1
fi

# --------------------------------------
# Renombrar IPA
# --------------------------------------
IPA_DESTINO="build/ios/ipa/app_quinielas-${VERSION}.ipa"

if [ "$IPA_ORIGINAL" != "$IPA_DESTINO" ]; then
    rm -f "$IPA_DESTINO"
    mv "$IPA_ORIGINAL" "$IPA_DESTINO"
fi

echo
echo "======================================"
echo "BUILD iOS COMPLETADO"
echo "======================================"
echo
echo "Archivo generado:"
echo "$IPA_DESTINO"
echo
