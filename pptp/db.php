<?php
    
    $localhost  = 'localhost'; // хост
    $dbuser     = 'root';      // имя пользователя
    $dbpassword = 'toor';          // пароль
    $database   = 'radius';      // база данных
    
    /*
     * Подключение к БД
     */
    $db = mysql_pconnect($localhost, $dbuser, $dbpassword) or die('В настоящий момент сервер базы данных не доступен.');  
    mysql_select_db($database, $db) or die ('В настоящий момент база данных не доступна.');?>