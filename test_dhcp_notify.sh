#!/bin/sh

# /usr/bin/test_dhcp_notify.sh
# Скрипт для тестирования уведомления о подключении DHCP-клиента

# --- Конфигурация ---
# Путь к основному скрипту уведомлений
NOTIFY_SCRIPT="/etc/hotplug.d/dhcp/98-client-join-notification"

# Проверяем, существует ли основной скрипт
if [ ! -f "$NOTIFY_SCRIPT" ]; then
    echo "Ошибка: Основной скрипт уведомлений '$NOTIFY_SCRIPT' не найден."
    exit 1
fi

# Проверяем, является ли он исполняемым
if [ ! -x "$NOTIFY_SCRIPT" ]; then
    echo "Ошибка: Основной скрипт '$NOTIFY_SCRIPT' не является исполняемым."
    echo "Попробуйте выполнить: chmod +x $NOTIFY_SCRIPT"
    exit 1
fi

# --- Имитация DHCPACK записи в лог ---
# Вы можете изменить эти значения для теста
TEST_INTERFACE="wlan0"
TEST_IP="192.168.1.250"
TEST_MAC="de:ad:be:ef:ca:fe"
TEST_HOSTNAME="TestDevice"

echo "Добавление тестовой записи DHCPACK в системный лог..."
# Добавляем тестовую строку в лог, имитируя DHCPACK от dnsmasq
# Формат должен соответствовать тому, что ожидает парсер в вашем основном скрипте
logger -t "dnsmasq-dhcp[$$]" "DHCPACK($TEST_INTERFACE) $TEST_IP $TEST_MAC $TEST_HOSTNAME"

# --- Вызов основного скрипта ---
echo "Вызов основного скрипта уведомлений с ACTION='add'..."
# Экспортируем ACTION и вызываем скрипт
export ACTION="add"
# Выполняем скрипт
"$NOTIFY_SCRIPT"

# Проверяем код возврата основного скрипта
if [ $? -eq 0 ]; then
    echo "Тест завершен успешно. Проверьте Telegram и системный лог (/tmp/log/messages или dmesg)."
else
    echo "Тест завершен с ошибкой. Проверьте системный лог для получения подробностей."
fi

# --- Необязательно: Проверка лога ---
echo ""
echo "Вы можете проверить последние записи в логе с помощью команд:"
echo "  logread -e 'dhcp-join-notify' | tail -n 10"
echo "  logread -e 'dnsmasq-dhcp' | grep DHCPACK | tail -n 5"
echo ""
echo "Также проверьте содержимое файла клиентов (если используется):"
echo "  cat /tmp/wifi_clients.txt | grep '$TEST_IP'"
