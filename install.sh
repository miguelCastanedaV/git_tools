#!/usr/bin/env bash

# Script de instalación automática de hooks para Laravel
# Descarga TODOS los scripts del repositorio automáticamente
# Uso: bash <(curl -fsSL https://raw.githubusercontent.com/miguelcastanedaV/git_tools/main/install.sh)

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}  Instalador Automático de Git Hooks  ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""

# Función para mostrar errores y salir
error_exit() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Verificar que estamos en un repositorio git
if [ ! -d .git ]; then
    error_exit "No se encontró un repositorio git\n   Ejecuta este script desde la raíz de tu proyecto Laravel"
fi

# Configuración
USER="miguelcastanedaV"
REPO="git_tools"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$USER/$REPO/$BRANCH"

HOOKS_DIR=".git/hooks"
SCRIPTS_DIR="$HOOKS_DIR/scripts"

# Crear directorios
mkdir -p "$SCRIPTS_DIR"

echo -e "${YELLOW}📦 Descargando archivos base...${NC}"

# 1. Descargar pre-commit hook principal
echo -e "${BLUE}•${NC} Descargando pre-commit hook..."
curl -fsSL "$BASE_URL/hooks/pre-commit" -o "$HOOKS_DIR/pre-commit" || {
    error_exit "Error al descargar pre-commit hook"
}

# 2. Descargar lista de scripts disponibles
echo -e "${BLUE}•${NC} Descargando lista de scripts..."
SCRIPT_LIST=$(curl -fsSL "$BASE_URL/scripts-list.txt" 2>/dev/null) || {
    error_exit "Error al descargar la lista de scripts"
}

# 3. Descargar cada script de la lista
echo -e "${BLUE}•${NC} Descargando scripts de validación..."
DOWNLOADED_COUNT=0

while IFS= read -r SCRIPT_NAME; do
    # Saltar líneas vacías y comentarios
    [[ -z "$SCRIPT_NAME" ]] && continue
    [[ "$SCRIPT_NAME" =~ ^#.* ]] && continue
    
    echo -e "  📥 Descargando: $SCRIPT_NAME"
    
    if curl -fsSL "$BASE_URL/hooks/scripts/$SCRIPT_NAME" -o "$SCRIPTS_DIR/$SCRIPT_NAME" 2>/dev/null; then
        chmod +x "$SCRIPTS_DIR/$SCRIPT_NAME"
        echo -e "    ${GREEN}✅ Descargado correctamente${NC}"
        DOWNLOADED_COUNT=$((DOWNLOADED_COUNT + 1))
    else
        echo -e "    ${YELLOW}⚠️  No disponible en el repositorio${NC}"
    fi
done <<< "$SCRIPT_LIST"

# Hacer ejecutable el pre-commit
chmod +x "$HOOKS_DIR/pre-commit"

# Verificar instalación
echo ""
echo -e "${GREEN}✅ Instalación completada${NC}"
echo ""
echo -e "${YELLOW}📁 Archivos instalados:${NC}"
echo "   📄 $HOOKS_DIR/pre-commit"
if [ $DOWNLOADED_COUNT -gt 0 ]; then
    echo "   📂 $SCRIPTS_DIR/"
    echo -e "${YELLOW}   📋 Scripts instalados ($DOWNLOADED_COUNT):${NC}"
    for script in "$SCRIPTS_DIR"/*.sh; do
        if [ -f "$script" ]; then
            echo "      • $(basename "$script")"
        fi
    done
else
    echo -e "${YELLOW}   ⚠️  No se descargaron scripts de validación${NC}"
fi

echo ""
echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}🎉 ¡Instalación completada exitosamente!${NC}"
echo -e "${GREEN}=======================================${NC}"
echo ""
echo -e "${YELLOW}📚 Para agregar más scripts:${NC}"
echo "   1. Agrega el script a hooks/scripts/"
echo "   2. Actualiza scripts-list.txt"
echo "   4. Ejecuta install.sh nuevamente en tus proyectos"
echo ""
echo -e "${GREEN}✅ ¡Listo!${NC}"