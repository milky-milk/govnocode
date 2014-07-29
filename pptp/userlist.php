<?php header('Content-Type: text/html; charset=utf-8'); ?>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="base.css">
	<style>
		table.table tr.header {
			background-color: #666;
			color: #fff;
		}
	</style>
	<title>Добавление аккаунта pptp/l2tp</title>
</head>
<body>
	<div align="center" style="float:left; padding:10px;">
	<?php		
		$host = 'localhost';
		$db = 'radius';
		$user = 'root';
		$password = 'toor';
		
		ini_set('display_errors',1);
error_reporting(E_ALL);
	
		$dbh = mysql_connect($host, $user, $password) or die("Could not connect to database:".mysql_error());
		mysql_select_db($db) or die("Could not connect to table:".mysql_error());		

		if (isset ($_POST['submit']))
		{
			$user = mysql_real_escape_string($_POST['username']);

			// $group = mysql_real_escape_string($_POST['groups']);
			
			$misc = mysql_real_escape_string($_POST['misc']);

	
			function createPassword($length) {
				$chars = "234567890abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
				$i = 0;
				$password = "";
				while ($i <= $length) {
					$password .= $chars{mt_rand(0,strlen($chars))};
					$i++;
				}
				return $password;
			}
	
			$new_pswd = createPassword(8);
			
			$query = "INSERT INTO `radcheck` (`UserName`, `Attribute`, `op`, `Value`, `misc`) VALUES ('".$user."', 'User-Password', ':=', '".$new_pswd."', '".$misc."');";				
			$sql = mysql_query($query);
			if(!$sql){echo mysql_error();}
			
			$query = "INSERT INTO `usergroup` (`UserName`, `GroupName`) VALUES ('".$user."', 'somegroup');";
			$sql = mysql_query($query);
			if(!$sql){echo mysql_error();}
			
			echo "Пользователь добавлен";
			
		}		
		
		$query = "SELECT `u`.`id`, `u`.`UserName`, `u`.`Value`, `u`.`misc` FROM `radcheck` `u` JOIN `usergroup` `g` ON `u`.`UserName` = `g`.`UserName`";
		$res = mysql_query($query);
		echo '<table class="table" border="1" width="800">
			<tr class="header"><td>id</td><td>UserName</td><td>Value</td><td>Примечание</td><td>Удалить?</td></tr>
		';
		while($row = mysql_fetch_array($res, MYSQL_BOTH))
		{
		    if($row['id'] != 756 && $row['id'] != 757 && $row['id'] != 766)
		    {
			echo '<tr>';
			echo '<td>'.$row['id'].'</td>';
			echo '<td>'.$row['UserName'].'</td>';
			echo '<td>'.$row['Value'].'</td>';
			echo '<td>'.$row['misc'].'</td>';
			echo '<td><input type="checkbox" name="checkbox[]" id="checkbox[]" value='.$row['id'].'></td>';
			echo '</tr>';
		    }
		}
		echo '</table><br />';
		echo '<input type="submit" name="delete" id="delete" value="delete"> ';
		echo "</table><p><input id='delete' type='submit' class='button' name='delete' value='Delete 2'/></p></form>";

		
$edittable=$_POST['checkbox'];
$N = count($edittable);
for($i=0; $i < $N; $i++)
{
	$result = mysql_query("DELETE FROM radcheck where id='$edittable[$i]'");
}

mysql_close();
		
		// mysql_close($dbh);
	?>
	</div>
	<div style="padding: 10px;">
	<fieldset style="width:250px;">
	<legend>Добавление пользователя</legend>
	<form method="POST" action="userlist.php" name="adduser" style="padding:10px;">
		<label for="username">Логин:</label>
		<input type="text" name="username" id="username"><br/>
		<!--- <h2>Примечание:</h2> --->
<!--		<input type="radio" id="group1" value="static-ip-vpn" checked="checked" name="groups" /> -->
	<label for="misc">Примечание:</label>
	<input type="text" name="misc" id="misc">
	<br/>
		<input type="submit" name="submit" value="Добавить" />
	</form>
	</fieldset>
	</div>	
</body>
</html>