<?php
include("dbconnection.php");
$con = dbconnection();

// Corrected SQL query
$query = "SELECT * FROM game";
$exe = mysqli_query($con, $query);

// Check for query execution error
if (!$exe) {
    die('Error: ' . mysqli_error($con));
}

$arr = [];

while ($row = mysqli_fetch_assoc($exe)) {
    $arr[] = $row;
}

// Corrected array name in json_encode function
print(json_encode($arr));
?>
