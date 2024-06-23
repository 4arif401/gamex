<?php
include("dbconnection.php"); // Include your database connection file
$con = dbconnection(); // Establish database connection

// Check if user_id is sent via POST
if (isset($_POST['user_id'])) {
    $userId = mysqli_real_escape_string($con, $_POST['user_id']);
    $query = "SELECT * FROM cart WHERE user_id = '$userId'";
    $exe = mysqli_query($con, $query);

    // Check for query execution error
    if (!$exe) {
        die('Error: ' . mysqli_error($con));
    }

    $arr = [];

    while ($row = mysqli_fetch_assoc($exe)) {
        $arr[] = $row;
    }

    // Set the content type to application/json
    header('Content-Type: application/json');

    // Output JSON encoded array
    print(json_encode($arr));

    // Close database connection
    mysqli_close($con);
} else {
    // If user_id is not provided, return an error response
    http_response_code(400); // Bad request
    echo json_encode(array('error' => 'Missing user_id parameter'));
    exit;
}

?>
