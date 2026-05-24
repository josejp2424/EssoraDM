#!/bin/bash
# autor josejp2424
# Autologin para EssoraDM
# Solo modifica auto_login.

ICON_PATH="/usr/share/essora-init/autologin/user.svg"

CONF_FILE="/etc/essoradm.conf"
DM_NAME="EssoraDM"

LANG_CODE=$(echo "${LANG:-en}" | cut -d '_' -f1 | tr '[:upper:]' '[:lower:]')
LANG_CODE_FULL=$(echo "${LANG:-en}" | tr '[:upper:]' '[:lower:]')

case "$LANG_CODE_FULL" in
    zh_cn*|zh-cn*) LANG_CODE="zh_cn" ;;
esac

set_language_strings() {
    case "$1" in
        ar)
            TITLE="إعدادات تسجيل الدخول التلقائي لـ $DM_NAME"
            ACTIVATE="تفعيل"
            DEACTIVATE="تعطيل"
            RESTART="إعادة التشغيل"
            EXIT="خروج"
            SELECT_OPTION="اختر خيارًا:"
            HELP_ACTIVATE="تفعيل تسجيل الدخول التلقائي في $DM_NAME"
            HELP_DEACTIVATE="تعطيل تسجيل الدخول التلقائي في $DM_NAME"
            ACTIVATE_MSG="تم تفعيل تسجيل الدخول التلقائي في $DM_NAME."
            DEACTIVATE_MSG="تم تعطيل تسجيل الدخول التلقائي في $DM_NAME."
            RESTART_MSG="هل ترغب في إعادة تشغيل $DM_NAME الآن لتطبيق التغييرات؟"
            RESTART_CONFIRM="تمت إعادة تشغيل $DM_NAME بنجاح."
            NO_CONF_MSG="لم يتم العثور على /etc/essoradm.conf."
            ;;
        ca)
            TITLE="Configuració d'autologin per a $DM_NAME"
            ACTIVATE="Activar"
            DEACTIVATE="Desactivar"
            RESTART="Reiniciar"
            EXIT="Sortir"
            SELECT_OPTION="Seleccioneu una opció:"
            HELP_ACTIVATE="Activa l'autologin a $DM_NAME"
            HELP_DEACTIVATE="Desactiva l'autologin a $DM_NAME"
            ACTIVATE_MSG="S'ha activat l'autologin a $DM_NAME."
            DEACTIVATE_MSG="S'ha desactivat l'autologin a $DM_NAME."
            RESTART_MSG="Vols reiniciar $DM_NAME ara per aplicar els canvis?"
            RESTART_CONFIRM="$DM_NAME s'ha reiniciat correctament."
            NO_CONF_MSG="No s'ha trobat /etc/essoradm.conf."
            ;;
        es)
            TITLE="Configuración de autologin para $DM_NAME"
            ACTIVATE="Activar"
            DEACTIVATE="Desactivar"
            RESTART="Reiniciar"
            EXIT="Salir"
            SELECT_OPTION="Seleccione una opción:"
            HELP_ACTIVATE="Activar autologin en $DM_NAME"
            HELP_DEACTIVATE="Desactivar autologin en $DM_NAME"
            ACTIVATE_MSG="El autologin para $DM_NAME ha sido activado."
            DEACTIVATE_MSG="El autologin para $DM_NAME ha sido desactivado."
            RESTART_MSG="¿Deseas reiniciar $DM_NAME ahora para aplicar los cambios?"
            RESTART_CONFIRM="$DM_NAME ha sido reiniciado correctamente."
            NO_CONF_MSG="No se encontró /etc/essoradm.conf."
            ;;
        fr)
            TITLE="Configuration de l'autologin pour $DM_NAME"
            ACTIVATE="Activer"
            DEACTIVATE="Désactiver"
            RESTART="Redémarrer"
            EXIT="Quitter"
            SELECT_OPTION="Sélectionnez une option:"
            HELP_ACTIVATE="Activer l'autologin dans $DM_NAME"
            HELP_DEACTIVATE="Désactiver l'autologin dans $DM_NAME"
            ACTIVATE_MSG="L'autologin pour $DM_NAME a été activé."
            DEACTIVATE_MSG="L'autologin pour $DM_NAME a été désactivé."
            RESTART_MSG="Voulez-vous redémarrer $DM_NAME maintenant pour appliquer les changements ?"
            RESTART_CONFIRM="$DM_NAME a été redémarré avec succès."
            NO_CONF_MSG="/etc/essoradm.conf introuvable."
            ;;
        it)
            TITLE="Configurazione autologin per $DM_NAME"
            ACTIVATE="Attiva"
            DEACTIVATE="Disattiva"
            RESTART="Riavvia"
            EXIT="Esci"
            SELECT_OPTION="Seleziona un'opzione:"
            HELP_ACTIVATE="Attiva l'autologin in $DM_NAME"
            HELP_DEACTIVATE="Disattiva l'autologin in $DM_NAME"
            ACTIVATE_MSG="L'autologin per $DM_NAME è stato attivato."
            DEACTIVATE_MSG="L'autologin per $DM_NAME è stato disattivato."
            RESTART_MSG="Vuoi riavviare $DM_NAME ora per applicare le modifiche?"
            RESTART_CONFIRM="$DM_NAME è stato riavviato con successo."
            NO_CONF_MSG="/etc/essoradm.conf non trovato."
            ;;
        pt)
            TITLE="Configuração de autologin para $DM_NAME"
            ACTIVATE="Ativar"
            DEACTIVATE="Desativar"
            RESTART="Reiniciar"
            EXIT="Sair"
            SELECT_OPTION="Selecione uma opção:"
            HELP_ACTIVATE="Ativar autologin no $DM_NAME"
            HELP_DEACTIVATE="Desativar autologin no $DM_NAME"
            ACTIVATE_MSG="O autologin para $DM_NAME foi ativado."
            DEACTIVATE_MSG="O autologin para $DM_NAME foi desativado."
            RESTART_MSG="Deseja reiniciar o $DM_NAME agora para aplicar as alterações?"
            RESTART_CONFIRM="$DM_NAME foi reiniciado com sucesso."
            NO_CONF_MSG="/etc/essoradm.conf não foi encontrado."
            ;;
        hu)
            TITLE="$DM_NAME automatikus bejelentkezés beállítása"
            ACTIVATE="Engedélyezés"
            DEACTIVATE="Letiltás"
            RESTART="Újraindítás"
            EXIT="Kilépés"
            SELECT_OPTION="Válasszon egy lehetőséget:"
            HELP_ACTIVATE="Automatikus bejelentkezés engedélyezése"
            HELP_DEACTIVATE="Automatikus bejelentkezés letiltása"
            ACTIVATE_MSG="Az automatikus bejelentkezés engedélyezve lett."
            DEACTIVATE_MSG="Az automatikus bejelentkezés le lett tiltva."
            RESTART_MSG="Újraindítja most a $DM_NAME szolgáltatást?"
            RESTART_CONFIRM="$DM_NAME sikeresen újraindítva."
            NO_CONF_MSG="/etc/essoradm.conf nem található."
            ;;
        ja)
            TITLE="$DM_NAME 自動ログイン設定"
            ACTIVATE="有効化"
            DEACTIVATE="無効化"
            RESTART="再起動"
            EXIT="終了"
            SELECT_OPTION="オプションを選択:"
            HELP_ACTIVATE="$DM_NAME の自動ログインを有効化"
            HELP_DEACTIVATE="$DM_NAME の自動ログインを無効化"
            ACTIVATE_MSG="$DM_NAME の自動ログインが有効になりました。"
            DEACTIVATE_MSG="$DM_NAME の自動ログインが無効になりました。"
            RESTART_MSG="変更を適用するために $DM_NAME を今すぐ再起動しますか？"
            RESTART_CONFIRM="$DM_NAME が正常に再起動されました。"
            NO_CONF_MSG="/etc/essoradm.conf が見つかりません。"
            ;;
        ru)
            TITLE="Настройка автовхода для $DM_NAME"
            ACTIVATE="Включить"
            DEACTIVATE="Отключить"
            RESTART="Перезапустить"
            EXIT="Выход"
            SELECT_OPTION="Выберите вариант:"
            HELP_ACTIVATE="Включить автоматический вход в $DM_NAME"
            HELP_DEACTIVATE="Отключить автоматический вход в $DM_NAME"
            ACTIVATE_MSG="Автовход для $DM_NAME включен."
            DEACTIVATE_MSG="Автовход для $DM_NAME отключен."
            RESTART_MSG="Хотите перезапустить $DM_NAME сейчас для применения изменений?"
            RESTART_CONFIRM="$DM_NAME успешно перезапущен."
            NO_CONF_MSG="/etc/essoradm.conf не найден."
            ;;
        zh_cn)
            TITLE="$DM_NAME 自动登录设置"
            ACTIVATE="启用"
            DEACTIVATE="禁用"
            RESTART="重启"
            EXIT="退出"
            SELECT_OPTION="请选择选项:"
            HELP_ACTIVATE="启用 $DM_NAME 自动登录"
            HELP_DEACTIVATE="禁用 $DM_NAME 自动登录"
            ACTIVATE_MSG="$DM_NAME 自动登录已启用。"
            DEACTIVATE_MSG="$DM_NAME 自动登录已禁用。"
            RESTART_MSG="是否立即重启 $DM_NAME 以应用更改？"
            RESTART_CONFIRM="$DM_NAME 已成功重启。"
            NO_CONF_MSG="未找到 /etc/essoradm.conf。"
            ;;
        *)
            TITLE="$DM_NAME Autologin Configuration"
            ACTIVATE="Activate"
            DEACTIVATE="Deactivate"
            RESTART="Restart"
            EXIT="Exit"
            SELECT_OPTION="Select an option:"
            HELP_ACTIVATE="Enable autologin in $DM_NAME"
            HELP_DEACTIVATE="Disable autologin in $DM_NAME"
            ACTIVATE_MSG="Autologin for $DM_NAME has been activated."
            DEACTIVATE_MSG="Autologin for $DM_NAME has been deactivated."
            RESTART_MSG="Do you want to restart $DM_NAME now to apply changes?"
            RESTART_CONFIRM="$DM_NAME has been restarted successfully."
            NO_CONF_MSG="/etc/essoradm.conf was not found."
            ;;
    esac
}

set_language_strings "$LANG_CODE"

show_error_no_conf() {
    yad --error --center --window-icon="$ICON_PATH" --image="$ICON_PATH" \
        --title="Autologin" \
        --text="$NO_CONF_MSG" \
        --button="OK":0 \
        --width=380
}

restart_dm() {
    if yad --question --center --window-icon="$ICON_PATH" --title="$RESTART" \
       --text="$RESTART_MSG" \
       --button="$RESTART:0" --button="$EXIT:1"; then

        sudo pkill -9 essoradm 2>/dev/null || true
        sudo essoradm &

        yad --info --center --window-icon="$ICON_PATH" --image="$ICON_PATH" \
            --title="$RESTART" \
            --text="$RESTART_CONFIRM" \
            --button="OK":0 \
            --width=320
    fi
}

activate_autologin() {
    if grep -qE '^[[:space:]]*#?[[:space:]]*auto_login[[:space:]]+' "$CONF_FILE"; then
        sudo sed -i 's|^[[:space:]]*#\?[[:space:]]*auto_login[[:space:]].*|auto_login          yes|' "$CONF_FILE"
    else
        echo "auto_login          yes" | sudo tee -a "$CONF_FILE" >/dev/null
    fi

    yad --info --center --window-icon="$ICON_PATH" --image="$ICON_PATH" \
       --title="$ACTIVATE" \
       --text="$ACTIVATE_MSG" \
       --button="OK":0 \
       --width=320 && restart_dm
}

deactivate_autologin() {
    if grep -qE '^[[:space:]]*#?[[:space:]]*auto_login[[:space:]]+' "$CONF_FILE"; then
        sudo sed -i 's|^[[:space:]]*#\?[[:space:]]*auto_login[[:space:]].*|auto_login          no|' "$CONF_FILE"
    else
        echo "auto_login          no" | sudo tee -a "$CONF_FILE" >/dev/null
    fi

    yad --info --center --window-icon="$ICON_PATH" --image="$ICON_PATH" \
       --title="$DEACTIVATE" \
       --text="$DEACTIVATE_MSG" \
       --button="OK":0 \
       --width=320 && restart_dm
}

if [ ! -f "$CONF_FILE" ]; then
    show_error_no_conf
    exit 1
fi

while true; do
    yad --center --window-icon="$ICON_PATH" --image="$ICON_PATH" \
        --title="$TITLE" \
        --text="$SELECT_OPTION\n\n$HELP_ACTIVATE\n\n$HELP_DEACTIVATE\n\nConfig: $CONF_FILE" \
        --button="$ACTIVATE":1 \
        --button="$DEACTIVATE":2 \
        --button="$EXIT":0 \
        --width=360 \
        --height=300

    ret=$?

    case $ret in
        1) activate_autologin ;;
        2) deactivate_autologin ;;
        *) exit 0 ;;
    esac
done
