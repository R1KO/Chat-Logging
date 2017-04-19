# Chat Logging

Плагин записывает весь чат сервера (и все админские сообщения) в mysql базу для дальнейшего вывода сообщений на сайте.

***Авторы:***
* [R1KO](http://hlmod.ru/members/r1ko.35068/)
* [Webman](http://hlmod.ru/members/webman.43023/)

[Пример WEB-части](http://m4us.ru/chat.php)

***Установка серверной части***
- Скачиваем последнюю версию.
- Заливаем `chat_logging.smx` в *`addons/sourcemod/plugins/`*
- Прописать в *`addons/sourcemod/configs/databases.cfg`*
    ```
    "chatlog"
    {
    	"driver"		"mysql"
    	"host"			"адрес_базы_данных"
    	"database"		"имя_базы_данных"
    	"user"			"имя_пользователя"
    	"pass"			"пароль"
    }
    ```

***Настройки***
- `sm_chat_log_table "chatlog"` - Таблица логов чата в базе данных
- `sm_chat_log_triggers "0"` - Запись в лог чат-триггеров
- `sm_chat_log_say "1"` - Запись в лог общего чата
- `sm_chat_log_say_team "1"` - Запись в лог командного чата
- `sm_chat_log_sm_say "1"` - Запись в лог команды sm_say
- `sm_chat_log_chat "1"` - Запись в лог команды sm_chat
- `sm_chat_log_csay "1"` - Запись в лог команды sm_csay
- `sm_chat_log_tsay "1"` - Запись в лог команды sm_tsay
- `sm_chat_log_msay "1"` - Запись в лог команды sm_msay
- `sm_chat_log_hsay "1"` - Запись в лог команды sm_hsay
- `sm_chat_log_psay "1"` - Запись в лог команды sm_psay

***Установка WEB-части***
- Скачиваем последнюю версию.
- Заливаем файлы из папки *`Web`* на WEB-сервер (ftp)
- Открываем файл *`chat.php`*, находим следующие строки:
    ```
    # Данные для подключения к базе данных
    $dbinfo_hostname = "";     // Хост
    $dbinfo_username = ""; // Имя пользователя
    $dbinfo_password = "";      // Пароль
    $dbinfo_dbtable = "";  // Название базы данных
    ```
- В кавычки вводим соответствующие данные базы данных - те, которые вы указали в файле `databases.cf`g на вашем сервере.
