#!/bin/bash

# ============================================================
# Pi-hole List Backup - Respaldo de dominios bloqueados
# ============================================================

PIHOLE_DB="/etc/pihole/gravity.db"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================
# Funciones auxiliares
# ============================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}[!] Este script requiere privilegios de administrador para acceder a la base de datos de Pi-hole.${NC}"
        echo -e "${YELLOW}[!] Solicitando permisos con sudo...${NC}"
        exec sudo bash "$0" "$@"
    fi
}

detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
        PKG_INSTALL="apt install -y"
    elif command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt-get"
        PKG_INSTALL="apt-get install -y"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="dnf install -y"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
        PKG_INSTALL="yum install -y"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        PKG_INSTALL="pacman -S --noconfirm"
    elif command -v brew &>/dev/null; then
        PKG_MANAGER="brew"
        PKG_INSTALL="brew install"
    else
        PKG_MANAGER=""
        PKG_INSTALL=""
    fi
}

install_package() {
    local pkg_name="$1"
    local brew_name="${2:-$pkg_name}"

    if [[ -z "$PKG_MANAGER" ]]; then
        detect_pkg_manager
    fi

    if [[ -z "$PKG_MANAGER" ]]; then
        echo -e "${RED}[ERROR] No se pudo detectar un gestor de paquetes compatible.${NC}"
        echo "Instala '$pkg_name' manualmente y vuelve a ejecutar el script."
        exit 1
    fi

    echo -e "${YELLOW}[*] Instalando '$pkg_name'...${NC}"

    if [[ "$PKG_MANAGER" == "brew" ]]; then
        local user="${SUDO_USER:-$USER}"
        if [[ $EUID -eq 0 ]]; then
            sudo -u "$user" brew install "$brew_name" 2>/dev/null || {
                echo -e "${RED}[ERROR] No se pudo instalar '$pkg_name' con Homebrew.${NC}"
                echo "Ejecuta manualmente: brew install $brew_name"
                exit 1
            }
        else
            brew install "$brew_name" 2>/dev/null || {
                echo -e "${RED}[ERROR] No se pudo instalar '$pkg_name' con Homebrew.${NC}"
                exit 1
            }
        fi
    else
        $PKG_INSTALL "$pkg_name" 2>/dev/null || {
            echo -e "${RED}[ERROR] No se pudo instalar '$pkg_name'.${NC}"
            echo "Instálalo manualmente y vuelve a ejecutar el script."
            exit 1
        }
    fi

    if command -v "$pkg_name" &>/dev/null; then
        echo -e "${GREEN}[✓] '$pkg_name' instalado correctamente.${NC}"
    else
        # brew no siempre deja el binario en PATH inmediatamente
        echo -e "${GREEN}[✓] Instalación de '$pkg_name' completada.${NC}"
    fi
}

check_prerequisites() {
    # Verificar que sqlite3 esté instalado
    if ! command -v sqlite3 &>/dev/null; then
        echo -e "${YELLOW}[!] sqlite3 no está instalado. Instalando...${NC}"
        install_package "sqlite3"
    fi

    # Verificar que python3 esté instalado (para el servidor HTTP)
    if ! command -v python3 &>/dev/null; then
        echo -e "${YELLOW}[!] python3 no está instalado. Instalando...${NC}"
        install_package "python3" "python"
    fi

    # Verificar que la base de datos de Pi-hole existe
    if [[ ! -f "$PIHOLE_DB" ]]; then
        echo -e "${RED}[ERROR] No se encontró la base de datos de Pi-hole en:${NC}"
        echo "  $PIHOLE_DB"
        echo "Asegúrate de que Pi-hole está instalado correctamente."
        exit 1
    fi

    # Verificar que la base de datos es accesible
    if ! sqlite3 "$PIHOLE_DB" "SELECT COUNT(*) FROM domainlist;" &>/dev/null; then
        echo -e "${RED}[ERROR] No se puede acceder a la base de datos de Pi-hole.${NC}"
        echo "Verifica los permisos del archivo: $PIHOLE_DB"
        exit 1
    fi
}

get_domains() {
    echo -e "${CYAN}[*] Obteniendo dominios bloqueados desde la base de datos...${NC}"

    # Tipos en domainlist: 0=exact, 1=regex, 2=whitelist
    # Tipos en domainlist_by_group: 0=exact, 1=regex, 2=whitelist
    # domainlist.type: 0=bloqueado, 1=permitido (allow), 2=regex (bloqueado), 3=regex (permitido)
    # En Pi-hole moderno: type 0 = black (exact), type 1 = white (exact),
    #   type 2 = black (regex), type 3 = white (regex)
    local domains
    domains=$(sqlite3 "$PIHOLE_DB" "
        SELECT domain FROM domainlist
        WHERE type IN (0, 2)
        ORDER BY domain ASC;
    ")

    if [[ -z "$domains" ]]; then
        echo -e "${YELLOW}[!] No se encontraron dominios bloqueados en la base de datos.${NC}"
        exit 0
    fi

    local count
    count=$(echo "$domains" | wc -l | tr -d ' ')
    echo -e "${GREEN}[✓] Se encontraron $count dominios bloqueados.${NC}"
    echo "$domains"
}

expand_path() {
    echo "${1/#\~/$HOME}"
}

ask_output_path() {
    local default_path="$HOME/pihole_blocklist.txt"

    echo -e "${CYAN}[?] ¿Dónde deseas guardar la lista de dominios?${NC}"
    echo -e "    (Presiona Enter para usar el directorio por defecto: $default_path)"
    read -r -p "    Ruta: " user_path

    if [[ -z "$user_path" ]]; then
        OUTPUT_PATH="$default_path"
    else
        OUTPUT_PATH=$(expand_path "$user_path")
    fi

    echo -e "${GREEN}[✓] La lista se guardará en: $OUTPUT_PATH${NC}"
}

ask_list_path() {
    local prompt="${1:-¿Cuál es la ruta del archivo de la lista?}"
    local default_path="$HOME/pihole_blocklist.txt"

    echo -e "${CYAN}[?] $prompt${NC}"
    echo -e "    (Presiona Enter para usar: $default_path)"
    read -r -p "    Ruta: " user_path

    if [[ -z "$user_path" ]]; then
        LIST_PATH="$default_path"
    else
        LIST_PATH=$(expand_path "$user_path")
    fi

    if [[ ! -f "$LIST_PATH" ]]; then
        echo -e "${RED}[ERROR] El archivo no existe: $LIST_PATH${NC}"
        exit 1
    fi

    echo -e "${GREEN}[✓] Usando archivo: $LIST_PATH${NC}"
}

write_domains() {
    local domains="$1"
    local tmpfile
    tmpfile=$(mktemp)

    echo "$domains" > "$tmpfile"

    if [[ -f "$OUTPUT_PATH" ]]; then
        echo -e "${YELLOW}[!] El archivo ya existe. Agregando solo dominios nuevos...${NC}"

        local existing_count
        existing_count=$(wc -l < "$OUTPUT_PATH" | tr -d ' ')

        # Combinar, ordenar y eliminar duplicados
        cat "$OUTPUT_PATH" "$tmpfile" | sort -u > "${tmpfile}_merged"
        mv "${tmpfile}_merged" "$OUTPUT_PATH"

        local final_count
        final_count=$(wc -l < "$OUTPUT_PATH" | tr -d ' ')
        local new_count=$((final_count - existing_count))
        echo -e "${GREEN}[✓] Se agregaron $new_count dominios nuevos. Total: $final_count${NC}"
    else
        mv "$tmpfile" "$OUTPUT_PATH"
        local final_count
        final_count=$(wc -l < "$OUTPUT_PATH" | tr -d ' ')
        echo -e "${GREEN}[✓] Lista creada con $final_count dominios.${NC}"
    fi

    rm -f "$tmpfile" "${tmpfile}_merged"
}

# ============================================================
# Funciones de GitHub
# ============================================================

check_git() {
    if ! command -v git &>/dev/null; then
        echo -e "${YELLOW}[!] git no está instalado. Instalando...${NC}"
        install_package "git"
    fi
    return 0
}

ask_github() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Subida opcional a GitHub${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}[?] ¿Deseas subir la lista a un repositorio de GitHub? (s/N)${NC}"
    read -r -p "    Respuesta: " github_choice

    case "$github_choice" in
        [sSyY]|[sS]|[yY][eE][sS]|[yY])
            GITHUB_ENABLED=true
            echo -e "${GREEN}[✓] Opción de GitHub habilitada.${NC}"
            ;;
        *)
            GITHUB_ENABLED=false
            echo -e "${YELLOW}[!] Se omitirá la subida a GitHub.${NC}"
            ;;
    esac
}

ask_github_config() {
    if [[ "$GITHUB_ENABLED" != true ]]; then
        return
    fi

    echo ""
    echo -e "${CYAN}[?] Configuración de GitHub:${NC}"

    echo -e "${CYAN}    ¿Cuál es tu nombre de usuario de GitHub?${NC}"
    read -r -p "    Usuario: " GITHUB_USER

    echo -e "${CYAN}    ¿Cuál es el nombre del repositorio? (ej: usuario/repo o solo repo)${NC}"
    read -r -p "    Repositorio: " GITHUB_REPO

    # Si solo es el nombre del repo, anteponer el usuario
    if [[ "$GITHUB_REPO" != *"/"* ]]; then
        GITHUB_REPO="${GITHUB_USER}/${GITHUB_REPO}"
    fi

    echo -e "${CYAN}    ¿Cuál es tu token de acceso personal de GitHub?${NC}"
    echo -e "${CYAN}    (Puedes crearlo en: Settings > Developer settings > Personal access tokens)${NC}"
    echo -e "${CYAN}    El token necesita permisos: repo${NC}"
    read -r -s -p "    Token: " GITHUB_TOKEN
    echo ""

    echo -e "${CYAN}    ¿Cuál es tu correo electrónico asociado a GitHub?${NC}"
    read -r -p "    Email: " GITHUB_EMAIL

    echo ""
    echo -e "${CYAN}[?] ¿Cómo deseas proceder con el repositorio?${NC}"
    echo "    1) Clonar un repositorio existente y actualizarlo"
    echo "    2) Usar el repositorio local (ya clonado en este directorio)"
    read -r -p "    Opción (1/2): " repo_option

    if [[ "$repo_option" == "1" ]]; then
        GITHUB_CLONE=true
        echo -e "${YELLOW}[!] Se clonará el repositorio y se subirá la lista.${NC}"
    else
        GITHUB_CLONE=false
        echo -e "${YELLOW}[!] Se usará el directorio actual como repositorio.${NC}"
    fi
}

upload_to_github() {
    local list_path="$1"
    local list_filename
    list_filename=$(basename "$list_path")

    if [[ "$GITHUB_ENABLED" != true ]] || [[ -z "$GITHUB_REPO" ]]; then
        return
    fi

    echo ""
    echo -e "${CYAN}[*] Preparando subida a GitHub...${NC}"

    if ! check_git; then
        return
    fi

    local work_dir
    local repo_dir_name
    repo_dir_name=$(basename "$GITHUB_REPO")

    if [[ "$GITHUB_CLONE" == true ]]; then
        work_dir=$(mktemp -d)

        echo -e "${CYAN}[*] Clonando repositorio $GITHUB_REPO ...${NC}"

        if ! git clone "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" "$work_dir" 2>/dev/null; then
            echo -e "${RED}[ERROR] No se pudo clonar el repositorio.${NC}"
            echo "Verifica las credenciales y la URL del repositorio."
            rm -rf "$work_dir"
            return
        fi
    else
        work_dir="$SCRIPT_DIR"
    fi

    local dest_path="$work_dir/$list_filename"

    # Copiar la lista al repositorio
    if [[ -f "$dest_path" ]]; then
        echo -e "${YELLOW}[!] La lista ya existe en el repositorio. Agregando solo dominios nuevos...${NC}"
        cat "$list_path" "$dest_path" | sort -u > "${dest_path}_new"
        mv "${dest_path}_new" "$dest_path"
    else
        cp "$list_path" "$dest_path"
    fi

    # Configurar git
    git -C "$work_dir" config user.name "$GITHUB_USER" 2>/dev/null
    git -C "$work_dir" config user.email "$GITHUB_EMAIL" 2>/dev/null

    # Hacer commit y push
    git -C "$work_dir" add "$list_filename" 2>/dev/null

    if git -C "$work_dir" diff --cached --quiet; then
        echo -e "${YELLOW}[!] No hay cambios nuevos para subir.${NC}"
    else
        git -C "$work_dir" commit -m "Actualizar lista de dominios bloqueados - $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
        echo -e "${CYAN}[*] Subiendo cambios a GitHub...${NC}"

        if git -C "$work_dir" push 2>/dev/null; then
            echo -e "${GREEN}[✓] Lista subida exitosamente a GitHub:${NC}"
            echo "    https://github.com/${GITHUB_REPO}/blob/main/${list_filename}"
        else
            echo -e "${RED}[ERROR] No se pudo subir al repositorio.${NC}"
            echo "Verifica las credenciales y los permisos del token."
        fi
    fi

    # Limpiar si clonamos
    if [[ "$GITHUB_CLONE" == true ]]; then
        rm -rf "$work_dir"
    fi
}

# ============================================================
# Funciones del servidor HTTP
# ============================================================

ask_http_server() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Servidor HTTP local${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}[?] ¿Deseas iniciar un servidor HTTP local para acceder a la lista? (s/N)${NC}"
    read -r -p "    Respuesta: " http_choice

    case "$http_choice" in
        [sSyY]|[sS]|[yY][eE][sS]|[yY])
            HTTP_SERVER_ENABLED=true
            echo -e "${GREEN}[✓] Servidor HTTP habilitado.${NC}"
            ;;
        *)
            HTTP_SERVER_ENABLED=false
            echo -e "${YELLOW}[!] Se omitirá el servidor HTTP.${NC}"
            ;;
    esac
}

start_http_server() {
    local list_path="$1"
    local list_dir
    list_dir=$(dirname "$list_path")
    local list_filename
    list_filename=$(basename "$list_path")
    local port=8080

    # Buscar un puerto disponible
    while lsof -i ":$port" &>/dev/null 2>&1; do
        port=$((port + 1))
    done

    echo ""
    echo -e "${GREEN}[✓] Servidor HTTP iniciado en:${NC}"
    echo ""
    echo -e "    ${CYAN}http://localhost:${port}/${list_filename}${NC}"
    echo ""

    # Obtener IPs locales no loopback
    local ips
    ips=$(ifconfig 2>/dev/null | grep -E 'inet ' | grep -v '127.0.0.1' | awk '{print $2}')
    if [[ -n "$ips" ]]; then
        echo -e "    Accesible desde otros dispositivos en la red:${NC}"
        echo "$ips" | while read -r ip; do
            echo -e "    ${CYAN}http://${ip}:${port}/${list_filename}${NC}"
        done
        echo ""
    fi

    echo -e "    ${YELLOW}Presiona Ctrl+C para detener el servidor${NC}"
    echo ""

    python3 -m http.server "$port" --directory "$list_dir"
}

# ============================================================
# Main - Menú principal
# ============================================================

show_menu() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        Pi-hole List Backup Tool              ║${NC}"
    echo -e "${CYAN}║     Respaldo de dominios bloqueados          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Generar respaldo"
    echo -e "  ${GREEN}2)${NC} Iniciar servidor HTTP"
    echo -e "  ${GREEN}3)${NC} Subir a GitHub"
    echo -e "  ${GREEN}0)${NC} Salir"
    echo ""
}

menu_generar_respaldo() {
    check_root "$@"
    check_prerequisites

    local domains
    domains=$(get_domains)

    ask_output_path
    write_domains "$domains"

    ask_github
    if [[ "$GITHUB_ENABLED" == true ]]; then
        ask_github_config
        upload_to_github "$OUTPUT_PATH"
    fi

    ask_http_server
    if [[ "$HTTP_SERVER_ENABLED" == true ]]; then
        start_http_server "$OUTPUT_PATH"
    fi

    echo ""
    echo -e "${GREEN}[✓] Proceso completado exitosamente.${NC}"
}

menu_servidor_http() {
    if ! command -v python3 &>/dev/null; then
        echo -e "${YELLOW}[!] python3 no está instalado. Instalando...${NC}"
        install_package "python3" "python"
    fi

    ask_list_path "¿Cuál es la ruta del archivo de lista que deseas servir?"
    start_http_server "$LIST_PATH"

    echo ""
    echo -e "${GREEN}[✓] Servidor HTTP finalizado.${NC}"
}

menu_subir_github() {
    check_git

    ask_list_path "¿Cuál es la ruta del archivo de lista que deseas subir?"

    GITHUB_ENABLED=true
    ask_github_config
    upload_to_github "$LIST_PATH"

    echo ""
    echo -e "${GREEN}[✓] Subida a GitHub completada.${NC}"
}

main() {
    local choice

    while true; do
        show_menu
        read -r -p "  Selecciona una opción: " choice

        case "$choice" in
            1)
                menu_generar_respaldo
                ;;
            2)
                menu_servidor_http
                ;;
            3)
                menu_subir_github
                ;;
            0)
                echo -e "${GREEN}[✓] Saliendo.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR] Opción inválida.${NC}"
                ;;
        esac

        echo ""
        echo -e "${YELLOW}[!] Presiona Enter para volver al menú...${NC}"
        read -r
    done
}

main "$@"
