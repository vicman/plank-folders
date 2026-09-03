# Traducciones del instalador. El idioma sale de LANGUAGE / LC_MESSAGES / LANG.
pg_detect_lang() {
  local spec="${LANGUAGE:-${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}}"
  spec="${spec%%:*}"
  spec="${spec%%.*}"
  spec="${spec%%@*}"
  case "$spec" in
    es|es_*|ES) echo es ;;
    pt_BR|pt_br) echo pt_BR ;;
    pt|pt_*|PT) echo pt ;;
    *) echo en ;;
  esac
}

PG_LANG="$(pg_detect_lang)"

pg() {
  case "$PG_LANG:$1" in
    es:title_install) echo "Grupos de Plank" ;;
    pt:title_install|pt_BR:title_install) echo "Grupos do Plank" ;;
    *:title_install) echo "Plank groups" ;;

    es:title_remove) echo "Quitar grupos de Plank" ;;
    pt:title_remove|pt_BR:title_remove) echo "Remover grupos do Plank" ;;
    *:title_remove) echo "Remove Plank groups" ;;

    es:press_enter) echo "Pulsa Enter para cerrar..." ;;
    pt:press_enter) echo "Prima Enter para fechar..." ;;
    pt_BR:press_enter) echo "Pressione Enter para fechar..." ;;
    *:press_enter) echo "Press Enter to close..." ;;

    es:open_terminal) echo "Abre una terminal en esta carpeta y ejecuta: ./install.sh" ;;
    pt:open_terminal) echo "Abra um terminal nesta pasta e execute: ./install.sh" ;;
    pt_BR:open_terminal) echo "Abra um terminal nesta pasta e execute: ./install.sh" ;;
    *:open_terminal) echo "Open a terminal in this folder and run: ./install.sh" ;;

    es:continue_prompt) echo "¿Continuar? [S/n] " ;;
    pt:continue_prompt) echo "Continuar? [S/n] " ;;
    pt_BR:continue_prompt) echo "Continuar? [S/n] " ;;
    *:continue_prompt) echo "Continue? [Y/n] " ;;

    es:err_root_install) echo "No ejecutes el instalador como administrador.\nÁbrelo con tu usuario; la contraseña se pedirá solo cuando haga falta." ;;
    pt:err_root_install) echo "Não execute o instalador como administrador.\nAbra-o com o seu utilizador; a palavra-passe só será pedida quando for necessário." ;;
    pt_BR:err_root_install) echo "Não execute o instalador como administrador.\nAbra-o com o seu usuário; a senha só será pedida quando for necessário." ;;
    *:err_root_install) echo "Do not run the installer as administrator.\nOpen it with your user account; the password is asked only when needed." ;;

    es:err_root_remove) echo "Ejecuta el desinstalador con tu usuario normal." ;;
    pt:err_root_remove) echo "Execute o desinstalador com o seu utilizador normal." ;;
    pt_BR:err_root_remove) echo "Execute o desinstalador com o seu usuário normal." ;;
    *:err_root_remove) echo "Run the uninstaller with your normal user account." ;;

    es:err_no_files) echo "No encuentro los archivos del proyecto.\nEjecuta el instalador desde la carpeta donde está el docklet." ;;
    pt:err_no_files) echo "Não encontro os ficheiros do projeto.\nExecute o instalador a partir da pasta do docklet." ;;
    pt_BR:err_no_files) echo "Não encontro os arquivos do projeto.\nExecute o instalador a partir da pasta do docklet." ;;
    *:err_no_files) echo "Project files were not found.\nRun the installer from the docklet folder." ;;

    es:err_not_debian) echo "Este instalador está preparado para Debian, Ubuntu, Linux Mint y similares." ;;
    pt:err_not_debian) echo "Este instalador está preparado para Debian, Ubuntu, Linux Mint e semelhantes." ;;
    pt_BR:err_not_debian) echo "Este instalador está preparado para Debian, Ubuntu, Linux Mint e similares." ;;
    *:err_not_debian) echo "This installer is meant for Debian, Ubuntu, Linux Mint and similar systems." ;;

    es:ask_start) echo "Este asistente instala los grupos de aplicaciones en Plank.\n\nHará tres cosas:\n• instalar lo necesario (si falta)\n• copiar el docklet al sistema\n• crear grupos de ejemplo, si quieres\n\n¿Empezamos?" ;;
    pt:ask_start) echo "Este assistente instala os grupos de aplicações no Plank.\n\nVai fazer três coisas:\n• instalar o necessário (se faltar)\n• copiar o docklet para o sistema\n• criar grupos de exemplo, se quiser\n\nComeçamos?" ;;
    pt_BR:ask_start) echo "Este assistente instala os grupos de aplicativos no Plank.\n\nVai fazer três coisas:\n• instalar o necessário (se faltar)\n• copiar o docklet para o sistema\n• criar grupos de exemplo, se quiser\n\nComeçamos?" ;;
    *:ask_start) echo "This assistant installs application groups in Plank.\n\nIt will:\n• install what is missing\n• copy the docklet onto the system\n• create sample groups, if you want\n\nStart now?" ;;

    es:missing_tools) echo "Faltan algunas herramientas de instalación.\nSe abrirá la ventana de contraseña." ;;
    pt:missing_tools) echo "Faltam algumas ferramentas de instalação.\nVai abrir a janela da palavra-passe." ;;
    pt_BR:missing_tools) echo "Faltam algumas ferramentas de instalação.\nVai abrir a janela da senha." ;;
    *:missing_tools) echo "Some install tools are missing.\nA password prompt will open." ;;

    es:missing_packages) echo "Faltan paquetes: %s\nSe pedirá tu contraseña de administrador." ;;
    pt:missing_packages) echo "Faltam pacotes: %s\nSerá pedida a palavra-passe de administrador." ;;
    pt_BR:missing_packages) echo "Faltam pacotes: %s\nSerá pedida a senha de administrador." ;;
    *:missing_packages) echo "Missing packages: %s\nYour administrator password will be requested." ;;

    es:err_deps) echo "No se pudieron instalar las dependencias.\n\n%s\n\nRegistro: %s" ;;
    pt:err_deps) echo "Não foi possível instalar as dependências.\n\n%s\n\nRegisto: %s" ;;
    pt_BR:err_deps) echo "Não foi possível instalar as dependências.\n\n%s\n\nRegistro: %s" ;;
    *:err_deps) echo "Dependencies could not be installed.\n\n%s\n\nLog: %s" ;;

    es:auth_cancelled) echo "Si cancelaste la contraseña, vuelve a intentarlo." ;;
    pt:auth_cancelled) echo "Se cancelou a palavra-passe, tente novamente." ;;
    pt_BR:auth_cancelled) echo "Se cancelou a senha, tente novamente." ;;
    *:auth_cancelled) echo "If you cancelled the password prompt, try again." ;;

    es:preparing) echo "Preparando la compilación" ;;
    pt:preparing) echo "A preparar a compilação" ;;
    pt_BR:preparing) echo "Preparando a compilação" ;;
    *:preparing) echo "Preparing the build" ;;

    es:compiling) echo "Compilando el docklet..." ;;
    pt:compiling) echo "A compilar o docklet..." ;;
    pt_BR:compiling) echo "Compilando o docklet..." ;;
    *:compiling) echo "Compiling the docklet..." ;;

    es:compiling_step) echo "Compilando el docklet" ;;
    pt:compiling_step) echo "A compilar o docklet" ;;
    pt_BR:compiling_step) echo "Compilando o docklet" ;;
    *:compiling_step) echo "Compiling the docklet" ;;

    es:err_compile) echo "No se pudo compilar el docklet.\n\nRegistro: %s" ;;
    pt:err_compile) echo "Não foi possível compilar o docklet.\n\nRegisto: %s" ;;
    pt_BR:err_compile) echo "Não foi possível compilar o docklet.\n\nRegistro: %s" ;;
    *:err_compile) echo "The docklet could not be compiled.\n\nLog: %s" ;;

    es:copying_module) echo "Ahora se copiará el docklet al sistema.\nSe pedirá la contraseña otra vez si hace falta." ;;
    pt:copying_module) echo "Agora o docklet será copiado para o sistema.\nA palavra-passe pode ser pedida outra vez." ;;
    pt_BR:copying_module) echo "Agora o docklet será copiado para o sistema.\nA senha pode ser pedida outra vez." ;;
    *:copying_module) echo "The docklet will now be copied onto the system.\nThe password may be asked again if needed." ;;

    es:err_install) echo "No se pudo copiar el docklet al sistema.\n\nRegistro: %s" ;;
    pt:err_install) echo "Não foi possível copiar o docklet para o sistema.\n\nRegisto: %s" ;;
    pt_BR:err_install) echo "Não foi possível copiar o docklet para o sistema.\n\nRegistro: %s" ;;
    *:err_install) echo "The docklet could not be copied onto the system.\n\nLog: %s" ;;

    es:ask_sample_groups) echo "¿Creo tres grupos (Desarrollo, Web y Comunicación) y los añado al dock?\n\nSolo se enlazan programas que ya tengas instalados.\nDespués puedes arrastrar más aplicaciones encima de cada grupo." ;;
    pt:ask_sample_groups) echo "Criar três grupos (Desenvolvimento, Web e Comunicação) e adicioná-los à dock?\n\nSó são ligados programas que já tenha instalados.\nDepois pode arrastar mais aplicações para cada grupo." ;;
    pt_BR:ask_sample_groups) echo "Criar três grupos (Desenvolvimento, Web e Comunicação) e adicioná-los ao dock?\n\nSó são ligados programas que você já tenha instalados.\nDepois você pode arrastar mais aplicativos para cada grupo." ;;
    *:ask_sample_groups) echo "Create three groups (Development, Web and Communication) and add them to the dock?\n\nOnly programs you already have installed are linked.\nYou can drag more applications onto each group afterwards." ;;

    es:group_dev) echo "Desarrollo" ;;
    pt:group_dev|pt_BR:group_dev) echo "Desenvolvimento" ;;
    *:group_dev) echo "Development" ;;

    es:group_web) echo "Web" ;;
    pt:group_web|pt_BR:group_web) echo "Web" ;;
    *:group_web) echo "Web" ;;

    es:group_chat) echo "Comunicación" ;;
    pt:group_chat|pt_BR:group_chat) echo "Comunicação" ;;
    *:group_chat) echo "Communication" ;;

    es:done_install) echo "Listo. El docklet ya está instalado.\n\n• Clic izquierdo en un grupo: ver sus aplicaciones\n• Arrastra un programa al icono del grupo para añadirlo\n• Clic derecho: cambiar el nombre o abrir la carpeta\n\nSi no ves los grupos: Ctrl + clic derecho en un hueco del dock → Añadir docklet → Grupo de aplicaciones.\n\nPara quitarlo más adelante: ./desinstalar.sh" ;;
    pt:done_install) echo "Concluído. O docklet já está instalado.\n\n• Clique esquerdo num grupo: ver as aplicações\n• Arraste um programa para o ícone do grupo para o adicionar\n• Clique direito: mudar o nome ou abrir a pasta\n\nSe não vir os grupos: Ctrl + clique direito num espaço da dock → Adicionar docklet → Grupo de aplicações.\n\nPara o remover mais tarde: ./desinstalar.sh" ;;
    pt_BR:done_install) echo "Pronto. O docklet já está instalado.\n\n• Clique esquerdo em um grupo: ver os aplicativos\n• Arraste um programa para o ícone do grupo para adicioná-lo\n• Clique direito: mudar o nome ou abrir a pasta\n\nSe não vir os grupos: Ctrl + clique direito em um espaço do dock → Adicionar docklet → Grupo de aplicativos.\n\nPara removê-lo depois: ./desinstalar.sh" ;;
    *:done_install) echo "Done. The docklet is installed.\n\n• Left-click a group to see its applications\n• Drag a program onto the group icon to add it\n• Right-click to rename it or open the folder\n\nIf you do not see the groups: Ctrl + right-click an empty area of the dock → Add docklet → Application group.\n\nTo remove it later: ./desinstalar.sh" ;;

    es:ask_remove) echo "Se quitará el docklet de grupos del sistema y sus iconos del dock.\nTus carpetas de aplicaciones no se borran salvo que lo pidas después.\n\n¿Quieres continuar?" ;;
    pt:ask_remove) echo "O docklet de grupos será removido do sistema e os seus ícones da dock.\nAs pastas de aplicações não são apagadas a menos que o peça a seguir.\n\nQuer continuar?" ;;
    pt_BR:ask_remove) echo "O docklet de grupos será removido do sistema e os seus ícones do dock.\nAs pastas de aplicativos não são apagadas, a menos que você peça em seguida.\n\nDeseja continuar?" ;;
    *:ask_remove) echo "The group docklet will be removed from the system and its icons from the dock.\nYour application folders are kept unless you choose to delete them next.\n\nContinue?" ;;

    es:err_delete_module) echo "No se pudo borrar el módulo del sistema." ;;
    pt:err_delete_module) echo "Não foi possível apagar o módulo do sistema." ;;
    pt_BR:err_delete_module) echo "Não foi possível apagar o módulo do sistema." ;;
    *:err_delete_module) echo "The system module could not be deleted." ;;

    es:ask_delete_folders) echo "¿Borro también la carpeta de grupos?\n%s" ;;
    pt:ask_delete_folders) echo "Apagar também a pasta de grupos?\n%s" ;;
    pt_BR:ask_delete_folders) echo "Apagar também a pasta de grupos?\n%s" ;;
    *:ask_delete_folders) echo "Also delete the groups folder?\n%s" ;;

    es:done_remove) echo "El docklet se ha quitado. Plank se ha reiniciado." ;;
    pt:done_remove) echo "O docklet foi removido. O Plank foi reiniciado." ;;
    pt_BR:done_remove) echo "O docklet foi removido. O Plank foi reiniciado." ;;
    *:done_remove) echo "The docklet has been removed. Plank was restarted." ;;

    *) echo "$1" ;;
  esac
}

pgf() {
  local key="$1"
  shift
  # shellcheck disable=SC2059
  printf "$(pg "$key")" "$@"
}
