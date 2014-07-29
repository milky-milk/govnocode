<?php 
    
    $search = $_POST['search'];
    $search = htmlspecialchars($search);
    
    //if($search == '')
    //    exit("Начните вводить запрос");
    //elseif(!preg_match("/^[a-z0-9]+$/ui", $search))  
    //    exit("Недопустимые символы в запросе");
    
    include 'db.php';
    
    $result = mysql_query("SELECT `UserName` FROM `radcheck` WHERE MATCH(`text`) AGAINST('".$search."')");
    
    if(mysql_num_rows($result) > 0)
        while($row = mysql_fetch_array($result))
            echo "<div>".$row['text']."</div>";
    else
	echo "Ничего не найдено";
    
?> 