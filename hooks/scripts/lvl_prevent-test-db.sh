#!/usr/bin/env bash

# Script: prevent-test-db.sh
# Propósito: Evitar commits con código de testing de base de datos
# Uso: Usado por git hook pre-commit

set -e  # Detener en caso de error

# Colores para mejor visualización
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


# Obtener archivos en staging (Added, Copied, Modified)
FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)

# Si no hay archivos, salir silenciosamente
if [ -z "$FILES" ]; then
    exit 0
fi

# Patrón a buscar (línea exacta que debe evitarse)
PATTERN='\Illuminate\Foundation\Testing\RefreshDatabaseState::$migrated = true;'

ERRORS=()
WARNINGS=0

# Separador para manejar nombres de archivo con espacios
IFS=$'\n'
for FILE in $FILES; do
    # Verificar que el archivo existe (podría ser eliminado)
    if [ -f "$FILE" ]; then
        # Buscar la línea exacta con grep -F (búsqueda literal)
        if grep -Fq "$PATTERN" "$FILE"; then
            ERRORS+=("$FILE")
            WARNINGS=$((WARNINGS + 1))
            
            # Mostrar información específica
            echo -e "${RED}❌ Problema encontrado en:${NC} $FILE"
            
            # Mostrar la línea y número de línea
            LINE_NUM=$(grep -n "$PATTERN" "$FILE" | cut -d: -f1)
            echo -e "   📍 Línea $LINE_NUM: ${RED}$PATTERN${NC}"
            
            # Sugerencia para corregir
            echo -e "   💡 ${YELLOW}Solución:${NC} Elimina esta línea antes de commitear"
            echo ""
        fi
    fi
done
unset IFS

# Resumen y bloqueo si hay errores
if [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "${RED}=================================================${NC}"
    echo -e "${RED}🚫 COMMIT BLOQUEADO${NC}"
    echo -e "${RED}=================================================${NC}"
    echo ""
    echo -e "${YELLOW}📋 Resumen de problemas:${NC}"
    echo -e "Se encontraron ${RED}$WARNINGS${NC} archivos con código de testing prohibido:"
    
    for ERROR_FILE in "${ERRORS[@]}"; do
        echo -e "  • ${RED}$ERROR_FILE${NC}"
    done
    
    echo ""
    echo -e "${YELLOW}📝 ¿Por qué se bloquea?${NC}"
    echo "Esta línea es para testing y nunca debe estar en producción:"
    echo -e "${RED}   $PATTERN${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Nota:${NC} Si es una emergencia, usa: ${GREEN}git commit --no-verify${NC}"
    echo ""
    exit 1
fi

exit 0
