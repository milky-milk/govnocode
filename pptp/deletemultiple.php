<?php
$con = mysql_connect("localhost","radius","toor");
if (!$con)
  {
  die('Could not connect: ' . mysql_error());
  }
mysql_select_db("radius", $con);

$edittable=$_POST['selector'];
$N = count($edittable);
for($i=0; $i < $N; $i++)
{
	$result = mysql_query("DELETE FROM `radcheck` where id='$edittable[$i]'");
}
header("location: index.php");
mysql_close($con);
?>
