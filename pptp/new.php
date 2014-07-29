<?php
$host="localhost"; // Host name 
$username="root"; // Mysql username 
$password="toor"; // Mysql password 
$db_name="radius"; // Database name 
$tbl_name="radcheck"; // Table name 

// Connect to server and select databse.
mysql_connect("$host", "$username", "$password")or die("cannot connect"); 
mysql_select_db("$db_name")or die("cannot select DB");

$sql="SELECT * FROM $tbl_name";
$result=mysql_query($sql);

$count=mysql_num_rows($result);
?>

<table width="400" border="0" cellspacing="1" cellpadding="0">
<tr>
<td><form name="form1" method="post" action="">
<table width="400" border="0" cellpadding="3" cellspacing="1" bgcolor="#CCCCCC">
<tr>
<td bgcolor="#FFFFFF">&nbsp;</td>
<td colspan="4" bgcolor="#FFFFFF"><strong>Delete multiple rows in mysql</strong> </td>
</tr>
<tr>
<td align="center" bgcolor="#FFFFFF">#</td>
<td align="center" bgcolor="#FFFFFF"><strong>Id</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>UserName</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Value</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>misc</strong></td>
</tr>

<?php
while($rows=mysql_fetch_array($result)){
?>

<tr>
<td align="center" bgcolor="#FFFFFF"><input name="checkbox[]" type="checkbox" id="checkbox[]" value="<? echo $rows['id']; ?>"></td>
<td bgcolor="#FFFFFF"><? echo $rows['id']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['UserName']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['Value']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['misc']; ?></td>
</tr>

<?php
}
?>

<tr>
<td colspan="5" align="center" bgcolor="#FFFFFF"><input name="delete" type="submit" id="delete" value="Delete"></td>
</tr>

<?php

// Check if delete button active, start this 
if(isset($_POST['delete'])){

for($i=0;$i<count($_POST['checkbox']);$i++){
$checkbox = $_POST['checkbox'];
// echo $checkbox;
$del_id = $checkbox[$i];
echo $del_id;
$sql = "DELETE FROM $tbl_name WHERE id=$del_id";
print $sql;
$result = mysql_query($sql);}
// if successful redirect to delete_multiple.php 
if($result){
echo '$id!';
}
}
mysql_close();
?>

</table>
</form>
</td>
</tr>
</table>