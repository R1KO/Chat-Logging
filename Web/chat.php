<?php

/*
* Chat Logging v 1.0
*
* Author web-side: Webman
* Copyright @ 2014
*
* Changelog:
* v1.0 - First release.
*/

header('Content-Type: text/html; charset=utf-8');

# Данные для подключения к базе данных
$dbinfo_hostname = "";     // Хост
$dbinfo_username = ""; // Имя пользователя
$dbinfo_password = "";      // Пароль
$dbinfo_dbtable = "";  // Название базы данных
$dbinfo_tablename = "chatlog"; // Название таблицы (квар sm_chat_log_table)

$dbinfo_link = "mysql:host=" . $dbinfo_hostname . ";dbname=" . $dbinfo_dbtable . "";

# Подключение к базе данных
try 
{ 
	$db = new PDO($dbinfo_link, $dbinfo_username, $dbinfo_password);
	$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	$db->exec("SET NAMES UTF8");
}

catch(PDOException $e) 
{
    print "Подключение не удалось. Отсутствует таблица либо неверно указаны данные для подключения.";
}

# Кол-во отображаемых последних сообщений. Default: 25
if (isset($_GET['num']))
{
	$limit = (int)$_GET['num'];
	if (!$limit)
	{
		$limit = 25;
	}
}
else $limit = 25;


$result = $db->query("SELECT * FROM `".$dbinfo_tablename."` ORDER BY `msg_id` DESC LIMIT 0, ".$limit.";");
$data = $result->fetchAll(PDO::FETCH_ASSOC);
$result->closeCursor();
unset($result);
$count = count($data);

?>

<html lang="ru">
<head>
<title>Chat Logging</title>
<link href="template/css/bootstrap.min.css" rel="stylesheet">
<link href="template/css/bootstrap.css" rel="stylesheet">
</head>
<body><br/>
	<div class="container">
		<nav class="navbar navbar-default" role="navigation">
			<div class="navbar-header">
				<a class="navbar-brand">Chat Logging</a>
				<p class="navbar-text pull-right">Лог записей чата</p>
			</div>
		</nav>
		<div class="row">
			<div class="col-md-12">
				Показывать записей:
					<div class="btn-group btn-group-sm">
						<a class="btn btn-default" href="?num=25">25</a>
						<a class="btn btn-default" href="?num=50">50</a>
						<a class="btn btn-default" href="?num=100">100</a>
					</div><br />
				<div class="panel panel-default">
					<div class="panel-heading">Чат</div>
					<div class="panel-body">
					<?php
					
					# Если чат пуст
					if ($count <= 0) print "<p class=\"text-center\">Чат пуст :(</p>";

					foreach ($data as $msg_info)
					{
						# Цвета команд (bootstrap css class text-*)
						$ingame = true;
						switch((int)$msg_info['team'])
						{
							case 1:
								$textcolor = "muted";
								break;
							case 2:
								$textcolor = "danger";
								break;
							case 3:
								$textcolor = "primary";
								break;
							default:
								$textcolor = "muted";
								$ingame = false;
								break;
						}

						# Командый чат - true/false
						$say_team = (bool)($msg_info['type'] == "say_team");
 					
						# Время написания сообщения
						print "<strong><span class=\"text-info\">[" . date("d-m H:i:s", $msg_info['timestamp']) . "]</span> ";
						
						# В наблюдателях/в команде - true/false
						$ingame = (bool)($msg_info['team'] == 0);
						
						# Игрок жив/мертв
						if ($msg_info['team'] > 1) AND (!$msg_info['alive'])) print "<span style=\"color: #ffb000;\">*DEAD*</span> ";
						
						# Приставки в зависимости от типа сообщения (basechat)
						if ($msg_info['type'] == "sm_hsay") print "<span class=\"text-success\">[HSAY]</span>";
						if ($msg_info['type'] == "sm_msay") print "<span class=\"text-success\">[MSAY]</span>";
						if ($msg_info['type'] == "sm_psay") print "<span class=\"text-success\">[PRIVATE]</span>";
						if ($msg_info['type'] == "sm_tsay") print "<span class=\"text-success\">[TSAY]</span>";
						if ($msg_info['type'] == "sm_say") print "<span class=\"text-success\">(ALL)</span>";
						if ($msg_info['type'] == "sm_csay") print "<span class=\"text-success\">[CSAY]</span>";
						
						# Цвет ника
						print "<span class=\"text-" .$textcolor. "\">";
						
						# Командый чат - приставка
						if($say_team) 
						{
							switch((int)$msg_info['team'])
							{
								case 2:
									$team = "(Террорист)";
									break;
								case 3:
									$team = "(Спецназовец)";
									break;
								default:
									$team = "(НАБЛЮДАТЕЛЬ)";
									break;
							}

							print $team;
						}
						
						# Ник игрока, который написал сообщение
						print " " . $msg_info['name'] . ":</span> ";
						
						# Текст сообщения (если psay - скрываем)
						if ($msg_info['type'] == "sm_psay") print "<span style=\"color: #ffb000;\">*ПРИВАТНОЕ СООБЩЕНИЕ*</span></strong><br>";
						else print "<span style=\"color: #ffb000;\">" . $msg_info['message'] . "</span></strong><br>";

					}

					# Закрываем соединие с базой данных
					$db = null;
					?>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<script src="//code.jquery.com/jquery.js"></script>
    <script src="template/js/bootstrap.min.js"></script>
	<script src="template/js/bootstrap-scrollspy.js"></script>
	
</body>
</html>