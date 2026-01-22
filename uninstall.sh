#!/usr/bin/env bash

# Script de desinstalación de hooks
# Uso: bash <(curl -fsSL https://raw.githubusercontent.com/miguelcastanedaV/git_tools/main/uninstall.sh)

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=======================================${NC}"
echo -e "${YELLOW}  Desinstalador de Git Hooks          ${NC}"
echo -e "${YELLOW}=======================================${NC}"
echo ""

# Verificar que estamos en un repositorio git
if [ ! -d .git ]; then
    echo -e "${RED}❌ No se encontró un repositorio git${NC}"
    exit 1
fi

HOOKS_DIR=".git/hooks"
FILES_REMOVED=0

# Eliminar archivos de hooks
if [ -f "$HOOKS_DIR/pre-commit" ]; then
    rm -f "$HOOKS_DIR/pre-commit"
    echo -e "${GREEN}✅ pre-commit eliminado${NC}"
    FILES_REMOVED=$((FILES_REMOVED + 1))
fi

# Eliminar directorio de scripts si existe
if [ -d "$HOOKS_DIR/scripts" ]; then
    SCRIPT_COUNT=$(ls -1 "$HOOKS_DIR/scripts/"*.sh 2>/dev/null | wc -l)
    rm -rf "$HOOKS_DIR/scripts"
    echo -e "${GREEN}✅ scripts eliminados ($SCRIPT_COUNT archivos)${NC}"
    FILES_REMOVED=$((FILES_REMOVED + SCRIPT_COUNT))
fi

# Eliminar archivos de configuración
for config_file in ".git-hooks-installed" ".git-hooks-config"; do
    if [ -f "$config_file" ]; then
        rm -f "$config_file"
        echo -e "${GREEN}✅ $config_file eliminado${NC}"
        FILES_REMOVED=$((FILES_REMOVED + 1))
    fi
done

echo ""
if [ $FILES_REMOVED -gt 0 ]; then
    echo -e "${GREEN}🎉 Desinstalación completada${NC}"
    echo -e "${GREEN}   Se eliminaron $FILES_REMOVED archivos${NC}"
else
    echo -e "${YELLOW}ℹ️  No se encontraron archivos para desinstalar${NC}"
fi

echo ""
echo -e "${YELLOW}⚠️  Nota:${NC} Los commits ya no serán validados automáticamente."
echo ""