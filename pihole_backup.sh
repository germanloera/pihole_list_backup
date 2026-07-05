#!/bin/bash

# ============================================================
# Pi-hole List Backup Tool
# ============================================================

PIHOLE_DB="/etc/pihole/gravity.db"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================
# Language / Translation System
# ============================================================

LANG_DEFAULT="en"

# --- English strings ---
STR_TITLE_EN="Pi-hole List Backup Tool"
STR_SUBTITLE_EN="Blocked domains backup"
STR_MENU_BACKUP_EN="Generate backup"
STR_MENU_HTTP_EN="Start HTTP server"
STR_MENU_GITHUB_EN="Upload to GitHub"
STR_MENU_LANG_EN="Change language"
STR_MENU_EXIT_EN="Exit"
STR_MENU_SELECT_EN="Select an option"
STR_MENU_BACK_EN="Press Enter to return to the menu..."
STR_EXIT_EN="Exiting."
STR_INVALID_OPT_EN="Invalid option."
STR_DONE_EN="Done successfully."

STR_ROOT_NEEDED_EN="This script requires administrator privileges to access the Pi-hole database."
STR_ROOT_REQUESTING_EN="Requesting privileges with sudo..."

STR_PKG_NOT_FOUND_EN="No compatible package manager found."
STR_PKG_MANUAL_EN='Install $1 manually and run the script again.'
STR_PKG_INSTALLING_EN='Installing $1...'
STR_PKG_BREW_FAIL_EN='Could not install $1 with Homebrew.'
STR_PKG_BREW_MANUAL_EN='Run manually: brew install $2'
STR_PKG_FAIL_EN='Could not install $1.'
STR_PKG_OK_EN='$1 installed successfully.'
STR_PKG_DONE_EN='Installation of $1 completed.'

STR_SQLITE_MISSING_EN="sqlite3 is not installed. Installing..."
STR_GIT_MISSING_EN="git is not installed. Installing..."
STR_PYTHON_MISSING_EN="python3 is not installed. Installing..."
STR_DB_NOT_FOUND_EN="Pi-hole database not found at:"
STR_DB_NOT_FOUND_HINT_EN="Make sure Pi-hole is properly installed."
STR_DB_NOT_ACCESSIBLE_EN="Cannot access the Pi-hole database."
STR_DB_NOT_ACCESSIBLE_HINT_EN='Check the file permissions: $1'

STR_DOMAIN_EXTRACTING_EN="Fetching blocked domains from the database..."
STR_DOMAIN_NONE_EN="No blocked domains found in the database."
STR_DOMAIN_COUNT_EN='Found $1 blocked domains.'

STR_ASK_SAVE_EN="Where do you want to save the domain list?"
STR_ASK_SAVE_DEFAULT_EN="(Press Enter for the default directory:"
STR_ASK_PATH_EN="Path:"
STR_LIST_SAVED_EN="The list will be saved at:"
STR_ASK_LIST_PATH_EN="What is the path of the list file?"
STR_ASK_LIST_DEFAULT_EN="(Press Enter for default:"
STR_LIST_USING_EN="Using file:"
STR_LIST_NOT_FOUND_EN="File not found:"

STR_FILE_EXISTS_EN="File already exists. Merging only new domains..."
STR_ADDED_COUNT_EN='Added $1 new domains. Total: $2'
STR_LIST_CREATED_EN='List created with $1 domains.'

STR_GITHUB_HEADER_EN="Optional GitHub upload"
STR_GITHUB_ASK_EN="Do you want to upload the list to a GitHub repository? (y/N)"
STR_GITHUB_ENABLED_EN="GitHub upload enabled."
STR_GITHUB_SKIP_EN="Skipping GitHub upload."
STR_GITHUB_CONFIG_EN="GitHub configuration:"
STR_GITHUB_USER_EN="What is your GitHub username?"
STR_GITHUB_USER_LBL_EN="Username:"
STR_GITHUB_REPO_EN="What is the repository name? (e.g. user/repo or just repo)"
STR_GITHUB_REPO_LBL_EN="Repository:"
STR_GITHUB_TOKEN_EN="What is your GitHub personal access token?"
STR_GITHUB_TOKEN_HINT_EN="(Create one at: Settings > Developer settings > Personal access tokens)"
STR_GITHUB_TOKEN_SCOPE_EN="The token needs repo scope."
STR_GITHUB_TOKEN_LBL_EN="Token:"
STR_GITHUB_EMAIL_EN="What is your GitHub-associated email?"
STR_GITHUB_EMAIL_LBL_EN="Email:"
STR_GITHUB_REPO_ASK_EN="How do you want to proceed with the repository?"
STR_GITHUB_REPO_CLONE_EN="1) Clone an existing repository and update it"
STR_GITHUB_REPO_LOCAL_EN="2) Use the local repository (already cloned in this directory)"
STR_GITHUB_REPO_OPT_EN="Option (1/2):"
STR_GITHUB_WILL_CLONE_EN="Will clone the repository and upload the list."
STR_GITHUB_WILL_LOCAL_EN="Will use the current directory as the repository."
STR_GITHUB_PREPARING_EN="Preparing GitHub upload..."
STR_GITHUB_CLONING_EN='Cloning repository $1 ...'
STR_GITHUB_CLONE_ERR_EN="Could not clone the repository."
STR_GITHUB_CLONE_HINT_EN="Check the credentials and the repository URL."
STR_GITHUB_EXISTS_EN="File already exists in the repository. Merging only new domains..."
STR_GITHUB_NO_CHANGES_EN="No new changes to upload."
STR_GITHUB_COMMIT_MSG_EN='Update blocked domains list - $1'
STR_GITHUB_PUSHING_EN="Pushing changes to GitHub..."
STR_GITHUB_PUSH_OK_EN="List successfully uploaded to GitHub:"
STR_GITHUB_PUSH_ERR_EN="Could not push to the repository."
STR_GITHUB_PUSH_HINT_EN="Check the credentials and the token permissions."

STR_HTTP_HEADER_EN="Local HTTP server"
STR_HTTP_ASK_EN="Do you want to start a local HTTP server to access the list? (y/N)"
STR_HTTP_ENABLED_EN="HTTP server enabled."
STR_HTTP_SKIP_EN="Skipping HTTP server."
STR_HTTP_STARTED_EN="HTTP server started at:"
STR_HTTP_NETWORK_EN="Accessible from other devices on the network:"
STR_HTTP_STOP_EN="Press Ctrl+C to stop the server"
STR_HTTP_FINALIZED_EN="HTTP server finalized."

STR_LANG_SELECT_EN="Select language / Seleccionar idioma:"
STR_LANG_EN_EN="English"
STR_LANG_ES_EN="Spanish"
STR_LANG_CHANGED_EN="Language set to English."

# --- Spanish strings ---
STR_TITLE_ES="Pi-hole List Backup Tool"
STR_SUBTITLE_ES="Respaldo de dominios bloqueados"
STR_MENU_BACKUP_ES="Generar respaldo"
STR_MENU_HTTP_ES="Iniciar servidor HTTP"
STR_MENU_GITHUB_ES="Subir a GitHub"
STR_MENU_LANG_ES="Cambiar idioma"
STR_MENU_EXIT_ES="Salir"
STR_MENU_SELECT_ES="Selecciona una opción"
STR_MENU_BACK_ES="Presiona Enter para volver al menú..."
STR_EXIT_ES="Saliendo."
STR_INVALID_OPT_ES="Opción inválida."
STR_DONE_ES="Proceso completado exitosamente."

STR_ROOT_NEEDED_ES="Este script requiere privilegios de administrador para acceder a la base de datos de Pi-hole."
STR_ROOT_REQUESTING_ES="Solicitando permisos con sudo..."

STR_PKG_NOT_FOUND_ES="No se pudo detectar un gestor de paquetes compatible."
STR_PKG_MANUAL_ES='Instala $1 manualmente y vuelve a ejecutar el script.'
STR_PKG_INSTALLING_ES='Instalando $1...'
STR_PKG_BREW_FAIL_ES='No se pudo instalar $1 con Homebrew.'
STR_PKG_BREW_MANUAL_ES='Ejecuta manualmente: brew install $2'
STR_PKG_FAIL_ES='No se pudo instalar $1.'
STR_PKG_OK_ES='$1 instalado correctamente.'
STR_PKG_DONE_ES='Instalación de $1 completada.'

STR_SQLITE_MISSING_ES="sqlite3 no está instalado. Instalando..."
STR_GIT_MISSING_ES="git no está instalado. Instalando..."
STR_PYTHON_MISSING_ES="python3 no está instalado. Instalando..."
STR_DB_NOT_FOUND_ES="No se encontró la base de datos de Pi-hole en:"
STR_DB_NOT_FOUND_HINT_ES="Asegúrate de que Pi-hole está instalado correctamente."
STR_DB_NOT_ACCESSIBLE_ES="No se puede acceder a la base de datos de Pi-hole."
STR_DB_NOT_ACCESSIBLE_HINT_ES='Verifica los permisos del archivo: $1'

STR_DOMAIN_EXTRACTING_ES="Obteniendo dominios bloqueados desde la base de datos..."
STR_DOMAIN_NONE_ES="No se encontraron dominios bloqueados en la base de datos."
STR_DOMAIN_COUNT_ES='Se encontraron $1 dominios bloqueados.'

STR_ASK_SAVE_ES="¿Dónde deseas guardar la lista de dominios?"
STR_ASK_SAVE_DEFAULT_ES="(Presiona Enter para usar el directorio por defecto:"
STR_ASK_PATH_ES="Ruta:"
STR_LIST_SAVED_ES="La lista se guardará en:"
STR_ASK_LIST_PATH_ES="¿Cuál es la ruta del archivo de lista?"
STR_ASK_LIST_DEFAULT_ES="(Presiona Enter para usar:"
STR_LIST_USING_ES="Usando archivo:"
STR_LIST_NOT_FOUND_ES="El archivo no existe:"

STR_FILE_EXISTS_ES="El archivo ya existe. Agregando solo dominios nuevos..."
STR_ADDED_COUNT_ES='Se agregaron $1 dominios nuevos. Total: $2'
STR_LIST_CREATED_ES='Lista creada con $1 dominios.'

STR_GITHUB_HEADER_ES="Subida opcional a GitHub"
STR_GITHUB_ASK_ES="¿Deseas subir la lista a un repositorio de GitHub? (s/N)"
STR_GITHUB_ENABLED_ES="Opción de GitHub habilitada."
STR_GITHUB_SKIP_ES="Se omitirá la subida a GitHub."
STR_GITHUB_CONFIG_ES="Configuración de GitHub:"
STR_GITHUB_USER_ES="¿Cuál es tu nombre de usuario de GitHub?"
STR_GITHUB_USER_LBL_ES="Usuario:"
STR_GITHUB_REPO_ES="¿Cuál es el nombre del repositorio? (ej: usuario/repo o solo repo)"
STR_GITHUB_REPO_LBL_ES="Repositorio:"
STR_GITHUB_TOKEN_ES="¿Cuál es tu token de acceso personal de GitHub?"
STR_GITHUB_TOKEN_HINT_ES="(Puedes crearlo en: Settings > Developer settings > Personal access tokens)"
STR_GITHUB_TOKEN_SCOPE_ES="El token necesita permisos: repo"
STR_GITHUB_TOKEN_LBL_ES="Token:"
STR_GITHUB_EMAIL_ES="¿Cuál es tu correo electrónico asociado a GitHub?"
STR_GITHUB_EMAIL_LBL_ES="Email:"
STR_GITHUB_REPO_ASK_ES="¿Cómo deseas proceder con el repositorio?"
STR_GITHUB_REPO_CLONE_ES="1) Clonar un repositorio existente y actualizarlo"
STR_GITHUB_REPO_LOCAL_ES="2) Usar el repositorio local (ya clonado en este directorio)"
STR_GITHUB_REPO_OPT_ES="Opción (1/2):"
STR_GITHUB_WILL_CLONE_ES="Se clonará el repositorio y se subirá la lista."
STR_GITHUB_WILL_LOCAL_ES="Se usará el directorio actual como repositorio."
STR_GITHUB_PREPARING_ES="Preparando subida a GitHub..."
STR_GITHUB_CLONING_ES='Clonando repositorio $1 ...'
STR_GITHUB_CLONE_ERR_ES="No se pudo clonar el repositorio."
STR_GITHUB_CLONE_HINT_ES="Verifica las credenciales y la URL del repositorio."
STR_GITHUB_EXISTS_ES="La lista ya existe en el repositorio. Agregando solo dominios nuevos..."
STR_GITHUB_NO_CHANGES_ES="No hay cambios nuevos para subir."
STR_GITHUB_COMMIT_MSG_ES='Actualizar lista de dominios bloqueados - $1'
STR_GITHUB_PUSHING_ES="Subiendo cambios a GitHub..."
STR_GITHUB_PUSH_OK_ES="Lista subida exitosamente a GitHub:"
STR_GITHUB_PUSH_ERR_ES="No se pudo subir al repositorio."
STR_GITHUB_PUSH_HINT_ES="Verifica las credenciales y los permisos del token."

STR_HTTP_HEADER_ES="Servidor HTTP local"
STR_HTTP_ASK_ES="¿Deseas iniciar un servidor HTTP local para acceder a la lista? (s/N)"
STR_HTTP_ENABLED_ES="Servidor HTTP habilitado."
STR_HTTP_SKIP_ES="Se omitirá el servidor HTTP."
STR_HTTP_STARTED_ES="Servidor HTTP iniciado en:"
STR_HTTP_NETWORK_ES="Accesible desde otros dispositivos en la red:"
STR_HTTP_STOP_ES="Presiona Ctrl+C para detener el servidor"
STR_HTTP_FINALIZED_ES="Servidor HTTP finalizado."

STR_LANG_SELECT_ES="Seleccionar idioma / Select language:"
STR_LANG_EN_ES="Inglés"
STR_LANG_ES_ES="Español"
STR_LANG_CHANGED_ES="Idioma cambiado a Español."

# Current language (default: english)
LANG_CODE="$LANG_DEFAULT"

t() {
    local key="$1"
    local lang_suffix
    lang_suffix=$(echo "$LANG_CODE" | tr '[:lower:]' '[:upper:]')
    local var="STR_${key}_${lang_suffix}"
    local val="${!var}"
    echo "$val"
}

ta() {
    local key="$1"
    shift
    local lang_suffix
    lang_suffix=$(echo "$LANG_CODE" | tr '[:lower:]' '[:upper:]')
    local var="STR_${key}_${lang_suffix}"
    local val="${!var}"
    local i=1
    for arg in "$@"; do
        val="${val//\$$i/$arg}"
        i=$((i + 1))
    done
    echo "$val"
}

# ============================================================
# Language selector
# ============================================================

choose_language() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $(t LANG_SELECT)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo "  1) $(t LANG_EN)"
    echo "  2) $(t LANG_ES)"
    echo ""
    echo -e "${CYAN}Select / Seleccionar:${NC}"
    read -r lang_choice
    case "$lang_choice" in
        2)
            LANG_CODE="es"
            ;;
        *)
            LANG_CODE="en"
            ;;
    esac
    echo -e "${GREEN}[✓] $(t LANG_CHANGED)${NC}"
}

# ============================================================
# Helper functions
# ============================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}[!] $(t ROOT_NEEDED)${NC}"
        echo -e "${YELLOW}[!] $(t ROOT_REQUESTING)${NC}"
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
        echo -e "${RED}[ERROR] $(t PKG_NOT_FOUND)${NC}"
        echo "$(ta PKG_MANUAL "$pkg_name")"
        exit 1
    fi

    echo -e "${YELLOW}[*] $(ta PKG_INSTALLING "$pkg_name")${NC}"

    if [[ "$PKG_MANAGER" == "brew" ]]; then
        local user="${SUDO_USER:-$USER}"
        if [[ $EUID -eq 0 ]]; then
            sudo -u "$user" brew install "$brew_name" 2>/dev/null || {
                echo -e "${RED}[ERROR] $(ta PKG_BREW_FAIL "$pkg_name")${NC}"
                echo "$(ta PKG_BREW_MANUAL "$pkg_name" "$brew_name")"
                exit 1
            }
        else
            brew install "$brew_name" 2>/dev/null || {
                echo -e "${RED}[ERROR] $(ta PKG_BREW_FAIL "$pkg_name")${NC}"
                exit 1
            }
        fi
    else
        $PKG_INSTALL "$pkg_name" 2>/dev/null || {
            echo -e "${RED}[ERROR] $(ta PKG_FAIL "$pkg_name")${NC}"
            echo "$(ta PKG_MANUAL "$pkg_name")"
            exit 1
        }
    fi

    if command -v "$pkg_name" &>/dev/null; then
        echo -e "${GREEN}[✓] $(ta PKG_OK "$pkg_name")${NC}"
    else
        echo -e "${GREEN}[✓] $(ta PKG_DONE "$pkg_name")${NC}"
    fi
}

check_prerequisites() {
    if ! command -v sqlite3 &>/dev/null; then
        echo -e "${YELLOW}[!] $(t SQLITE_MISSING)${NC}"
        install_package "sqlite3"
    fi

    if ! command -v python3 &>/dev/null; then
        echo -e "${YELLOW}[!] $(t PYTHON_MISSING)${NC}"
        install_package "python3" "python"
    fi

    if [[ ! -f "$PIHOLE_DB" ]]; then
        echo -e "${RED}[ERROR] $(t DB_NOT_FOUND)${NC}"
        echo "  $PIHOLE_DB"
        echo "$(t DB_NOT_FOUND_HINT)"
        exit 1
    fi

    if ! sqlite3 "$PIHOLE_DB" "SELECT COUNT(*) FROM domainlist;" &>/dev/null; then
        echo -e "${RED}[ERROR] $(t DB_NOT_ACCESSIBLE)${NC}"
        echo "$(ta DB_NOT_ACCESSIBLE_HINT "$PIHOLE_DB")"
        exit 1
    fi
}

get_domains() {
    echo -e "${CYAN}[*] $(t DOMAIN_EXTRACTING)${NC}"

    local domains
    domains=$(sqlite3 "$PIHOLE_DB" "
        SELECT DISTINCT g.domain
        FROM gravity g
        INNER JOIN adlist a ON g.adlist_id = a.id
        LEFT JOIN domainlist d ON g.domain = d.domain AND d.type = 0 AND d.enabled = 1
        WHERE a.enabled = 1
            AND d.domain IS NULL;
    ")

    if [[ -z "$domains" ]]; then
        echo -e "${YELLOW}[!] $(t DOMAIN_NONE)${NC}"
        exit 0
    fi

    local count
    count=$(echo "$domains" | wc -l | tr -d ' ')
    echo -e "${GREEN}[✓] $(ta DOMAIN_COUNT "$count")${NC}"
    echo "$domains"
}

expand_path() {
    echo "${1/#\~/$HOME}"
}

ask_output_path() {
    local default_path="$HOME/pihole_blocklist.txt"

    echo -e "${CYAN}[?] $(t ASK_SAVE)${NC}"
    echo -e "    $(t ASK_SAVE_DEFAULT) $default_path)"
    read -r -p "    $(t ASK_PATH) " user_path

    if [[ -z "$user_path" ]]; then
        OUTPUT_PATH="$default_path"
    else
        OUTPUT_PATH=$(expand_path "$user_path")
    fi

    echo -e "${GREEN}[✓] $(t LIST_SAVED) $OUTPUT_PATH${NC}"
}

ask_list_path() {
    local default_path="$HOME/pihole_blocklist.txt"

    echo -e "${CYAN}[?] $(t ASK_LIST_PATH)${NC}"
    echo -e "    $(t ASK_LIST_DEFAULT) $default_path)"
    read -r -p "    $(t ASK_PATH) " user_path

    if [[ -z "$user_path" ]]; then
        LIST_PATH="$default_path"
    else
        LIST_PATH=$(expand_path "$user_path")
    fi

    if [[ ! -f "$LIST_PATH" ]]; then
        echo -e "${RED}[ERROR] $(t LIST_NOT_FOUND) $LIST_PATH${NC}"
        exit 1
    fi

    echo -e "${GREEN}[✓] $(t LIST_USING) $LIST_PATH${NC}"
}

write_domains() {
    local domains="$1"
    local tmpfile
    tmpfile=$(mktemp)

    echo "$domains" > "$tmpfile"

    if [[ -f "$OUTPUT_PATH" ]]; then
        echo -e "${YELLOW}[!] $(t FILE_EXISTS)${NC}"

        local existing_count
        existing_count=$(wc -l < "$OUTPUT_PATH" | tr -d ' ')

        cat "$OUTPUT_PATH" "$tmpfile" | sort -u > "${tmpfile}_merged"
        mv "${tmpfile}_merged" "$OUTPUT_PATH"

        local final_count
        final_count=$(wc -l < "$OUTPUT_PATH" | tr -d ' ')
        local new_count=$((final_count - existing_count))
        echo -e "${GREEN}[✓] $(ta ADDED_COUNT "$new_count" "$final_count")${NC}"
    else
        mv "$tmpfile" "$OUTPUT_PATH"
        local final_count
        final_count=$(wc -l < "$OUTPUT_PATH" | tr -d ' ')
        echo -e "${GREEN}[✓] $(ta LIST_CREATED "$final_count")${NC}"
    fi

    rm -f "$tmpfile" "${tmpfile}_merged"
}

# ============================================================
# GitHub functions
# ============================================================

check_git() {
    if ! command -v git &>/dev/null; then
        echo -e "${YELLOW}[!] $(t GIT_MISSING)${NC}"
        install_package "git"
    fi
    return 0
}

ask_github() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $(t GITHUB_HEADER)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}[?] $(t GITHUB_ASK)${NC}"
    read -r -p "    $(t GITHUB_TOKEN_LBL) " github_choice

    case "$github_choice" in
        [sSyY]|[sS]|[yY][eE][sS]|[yY])
            GITHUB_ENABLED=true
            echo -e "${GREEN}[✓] $(t GITHUB_ENABLED)${NC}"
            ;;
        *)
            GITHUB_ENABLED=false
            echo -e "${YELLOW}[!] $(t GITHUB_SKIP)${NC}"
            ;;
    esac
}

ask_github_config() {
    if [[ "$GITHUB_ENABLED" != true ]]; then
        return
    fi

    echo ""
    echo -e "${CYAN}[?] $(t GITHUB_CONFIG)${NC}"

    echo -e "${CYAN}    $(t GITHUB_USER)${NC}"
    read -r -p "    $(t GITHUB_USER_LBL) " GITHUB_USER

    echo -e "${CYAN}    $(t GITHUB_REPO)${NC}"
    read -r -p "    $(t GITHUB_REPO_LBL) " GITHUB_REPO

    if [[ "$GITHUB_REPO" != *"/"* ]]; then
        GITHUB_REPO="${GITHUB_USER}/${GITHUB_REPO}"
    fi

    echo -e "${CYAN}    $(t GITHUB_TOKEN)${NC}"
    echo -e "${CYAN}    $(t GITHUB_TOKEN_HINT)${NC}"
    echo -e "${CYAN}    $(t GITHUB_TOKEN_SCOPE)${NC}"
    read -r -s -p "    $(t GITHUB_TOKEN_LBL) " GITHUB_TOKEN
    echo ""

    echo -e "${CYAN}    $(t GITHUB_EMAIL)${NC}"
    read -r -p "    $(t GITHUB_EMAIL_LBL) " GITHUB_EMAIL

    echo ""
    echo -e "${CYAN}[?] $(t GITHUB_REPO_ASK)${NC}"
    echo "    $(t GITHUB_REPO_CLONE)"
    echo "    $(t GITHUB_REPO_LOCAL)"
    read -r -p "    $(t GITHUB_REPO_OPT) " repo_option

    if [[ "$repo_option" == "1" ]]; then
        GITHUB_CLONE=true
        echo -e "${YELLOW}[!] $(t GITHUB_WILL_CLONE)${NC}"
    else
        GITHUB_CLONE=false
        echo -e "${YELLOW}[!] $(t GITHUB_WILL_LOCAL)${NC}"
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
    echo -e "${CYAN}[*] $(t GITHUB_PREPARING)${NC}"

    if ! check_git; then
        return
    fi

    local work_dir
    local repo_dir_name
    repo_dir_name=$(basename "$GITHUB_REPO")

    if [[ "$GITHUB_CLONE" == true ]]; then
        work_dir=$(mktemp -d)

        echo -e "${CYAN}[*] $(ta GITHUB_CLONING "$GITHUB_REPO")${NC}"

        if ! git clone "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" "$work_dir" 2>/dev/null; then
            echo -e "${RED}[ERROR] $(t GITHUB_CLONE_ERR)${NC}"
            echo "$(t GITHUB_CLONE_HINT)"
            rm -rf "$work_dir"
            return
        fi
    else
        work_dir="$SCRIPT_DIR"
    fi

    local dest_path="$work_dir/$list_filename"

    if [[ -f "$dest_path" ]]; then
        echo -e "${YELLOW}[!] $(t GITHUB_EXISTS)${NC}"
        cat "$list_path" "$dest_path" | sort -u > "${dest_path}_new"
        mv "${dest_path}_new" "$dest_path"
    else
        cp "$list_path" "$dest_path"
    fi

    git -C "$work_dir" config user.name "$GITHUB_USER" 2>/dev/null
    git -C "$work_dir" config user.email "$GITHUB_EMAIL" 2>/dev/null

    git -C "$work_dir" add "$list_filename" 2>/dev/null

    if git -C "$work_dir" diff --cached --quiet; then
        echo -e "${YELLOW}[!] $(t GITHUB_NO_CHANGES)${NC}"
    else
        local commit_msg
        commit_msg=$(ta GITHUB_COMMIT_MSG "$(date '+%Y-%m-%d %H:%M')")
        git -C "$work_dir" commit -m "$commit_msg" 2>/dev/null
        echo -e "${CYAN}[*] $(t GITHUB_PUSHING)${NC}"

        if git -C "$work_dir" push 2>/dev/null; then
            echo -e "${GREEN}[✓] $(t GITHUB_PUSH_OK)${NC}"
            echo "    https://github.com/${GITHUB_REPO}/blob/main/${list_filename}"
        else
            echo -e "${RED}[ERROR] $(t GITHUB_PUSH_ERR)${NC}"
            echo "$(t GITHUB_PUSH_HINT)"
        fi
    fi

    if [[ "$GITHUB_CLONE" == true ]]; then
        rm -rf "$work_dir"
    fi
}

# ============================================================
# HTTP server functions
# ============================================================

ask_http_server() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $(t HTTP_HEADER)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}[?] $(t HTTP_ASK)${NC}"
    read -r -p "    $(t GITHUB_TOKEN_LBL) " http_choice

    case "$http_choice" in
        [sSyY]|[sS]|[yY][eE][sS]|[yY])
            HTTP_SERVER_ENABLED=true
            echo -e "${GREEN}[✓] $(t HTTP_ENABLED)${NC}"
            ;;
        *)
            HTTP_SERVER_ENABLED=false
            echo -e "${YELLOW}[!] $(t HTTP_SKIP)${NC}"
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

    while lsof -i ":$port" &>/dev/null 2>&1; do
        port=$((port + 1))
    done

    echo ""
    echo -e "${GREEN}[✓] $(t HTTP_STARTED)${NC}"
    echo ""
    echo -e "    ${CYAN}http://localhost:${port}/${list_filename}${NC}"
    echo ""

    local ips
    ips=$(ifconfig 2>/dev/null | grep -E 'inet ' | grep -v '127.0.0.1' | awk '{print $2}')
    if [[ -n "$ips" ]]; then
        echo -e "    $(t HTTP_NETWORK)${NC}"
        echo "$ips" | while read -r ip; do
            echo -e "    ${CYAN}http://${ip}:${port}/${list_filename}${NC}"
        done
        echo ""
    fi

    echo -e "    ${YELLOW}$(t HTTP_STOP)${NC}"
    echo ""

    python3 -m http.server "$port" --directory "$list_dir"
}

# ============================================================
# Main menu
# ============================================================

show_menu() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  $(t TITLE)${NC}"
    echo -e "${CYAN}║  $(t SUBTITLE)${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} $(t MENU_BACKUP)"
    echo -e "  ${GREEN}2)${NC} $(t MENU_HTTP)"
    echo -e "  ${GREEN}3)${NC} $(t MENU_GITHUB)"
    echo -e "  ${GREEN}4)${NC} $(t MENU_LANG)"
    echo -e "  ${GREEN}0)${NC} $(t MENU_EXIT)"
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
    echo -e "${GREEN}[✓] $(t DONE)${NC}"
}

menu_servidor_http() {
    if ! command -v python3 &>/dev/null; then
        echo -e "${YELLOW}[!] $(t PYTHON_MISSING)${NC}"
        install_package "python3" "python"
    fi

    ask_list_path
    start_http_server "$LIST_PATH"

    echo ""
    echo -e "${GREEN}[✓] $(t HTTP_FINALIZED)${NC}"
}

menu_subir_github() {
    check_git

    ask_list_path

    GITHUB_ENABLED=true
    ask_github_config
    upload_to_github "$LIST_PATH"

    echo ""
    echo -e "${GREEN}[✓] $(t DONE)${NC}"
}

main() {
    local choice

    choose_language

    while true; do
        show_menu
        read -r -p "  $(t MENU_SELECT): " choice

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
            4)
                choose_language
                continue
                ;;
            0)
                echo -e "${GREEN}[✓] $(t EXIT)${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR] $(t INVALID_OPT)${NC}"
                ;;
        esac

        echo ""
        echo -e "${YELLOW}[!] $(t MENU_BACK)${NC}"
        read -r
    done
}

main "$@"
