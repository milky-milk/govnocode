<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script src="js/jquery.tablesorter.js"></script>

<style>
body {
	font: normal 11px auto "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
	color: #4f6b72;
	background: #E6EAE9;
}

a {
	color: #c75f3e;
}

#mytable {
	width: 700px;
	padding: 0;
	margin: 0;
}

caption {
	padding: 0 0 5px 0;
	width: 700px;	 
	font: italic 11px "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
	text-align: right;
}

th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
	color: #4f6b72;
	border-right: 1px solid #C1DAD7;
	border-bottom: 1px solid #C1DAD7;
	border-top: 1px solid #C1DAD7;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #CAE8EA url(bg_header.jpg) no-repeat;
	cursor: pointer;
}

th.nobg {
	border-top: 0;
	border-left: 0;
	border-right: 1px solid #C1DAD7;
	background: none;
}

td {
	border-right: 1px solid #C1DAD7;
	border-bottom: 1px solid #C1DAD7;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #4f6b72;
}


td.alt {
	background: #F5FAFA;
	color: #797268;
}

th.spec {
	border-left: 1px solid #C1DAD7;
	border-top: 0;
	background: #fff url(bullet1.gif) no-repeat;
	font: bold 10px "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
}

th.specalt {
	border-left: 1px solid #C1DAD7;
	border-top: 0;
	background: #f5fafa url(bullet2.gif) no-repeat;
	font: bold 10px "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
	color: #797268;
}
button.mult_submit {
    background-color: transparent;
    border: 1px solid #336699;
    border-radius: 36px 36px 36px 36px;
    padding: 5px;
	margin-top: 9px;
	cursor:pointer;
}
img, input, select, button {
    vertical-align: middle;
}
button {
    display: inline;
}
.nowrap {
    white-space: nowrap;
}
.icon {
    margin-left: 0.3em;
    margin-right: 0.3em;
    vertical-align: -3px;
}
</style>
<form action="deletemultiple.php" method="post">
<?php
$con = mysql_connect("localhost","radius","password");
if (!$con)
  {
  die('Could not connect: ' . mysql_error());
  }

mysql_select_db("radius", $con);

$result = mysql_query("SELECT * FROM radcheck");



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
			header ("Location: index.php");
			echo "Пользователь добавлен";
			
		}




echo '<table id="mytable" cellspacing="0" summary="The technical
specifications of the Apple PowerMac G5 series">
<thead>
<tr>
  <th scope="col" abbr="" class="nobg">&nbsp;&nbsp;</th>
  <th scope="col" abbr="UserName" style="width: 159px;">username</th>
  <th scope="col" abbr="Value" style="width: 159px;">password</th>
  <th scope="col" abbr="misc" style="width: 259px;">misc</th>
</tr>
</thead>
';
echo "<tbody>";
while($row = mysql_fetch_array($result))
  {
  echo "<tr>";
  echo "<th scope='row' class='spec'>" . '<input name="selector[]" type="checkbox" value="'.$row['id'].'">' . "</th>";
  echo "<td>" . $row['UserName'] . "</td>";
  echo "<td>" . $row['Value'] . "</td>";
  echo "<td style='overflow:hidden;'>" . $row['misc'] . "</td>";
  echo "</tr>";
  }
echo "</tbody>";
echo "</table>";

mysql_close($con);
?>
<button class="mult_submit" title="Change" value="edit" name="submit_mult" type="submit" style="padding-left: 0px;">
<span class="nowrap">
<img class="icon" width="16" height="16" alt="Change" title="Change" src="b_drop.png">
Delete
</span>
</button>
</form>

	<div style="padding: 10px; float: right; text-align: left; position: fixed; top: 10px; right: 10px">
	<fieldset style="width:300px; float: right; text-align: right;">
	<legend>Добавление пользователя</legend>
	<form method="POST" action="index.php" name="adduser" style="padding:10px;">
		<label for="username">Логин:</label>
		<input type="text" name="username" id="username"><br/>
	<label for="misc">Примечание:</label>
	<input type="text" name="misc" id="misc">

	<input type="submit" name="submit" value="Добавить" />

    </div>

	</fieldset>
	</div>
<script>
$(document).ready(function()
    {
        $("#mytable").tablesorter();
    }
);
</script>

