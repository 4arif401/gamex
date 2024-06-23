<?php
include("dbconnection.php"); // Include your database connection file
$con = dbconnection(); // Establish database connection

// Check if user_id and game_id are sent via POST
if (isset($_POST['user_id']) && isset($_POST['game_id'])) {
    $userId = mysqli_real_escape_string($con, $_POST['user_id']);
    $gameId = mysqli_real_escape_string($con, $_POST['game_id']);

    // Construct DELETE query
    $query = "DELETE FROM cart WHERE user_id = '$userId' AND game_id = '$gameId'";

    // Execute the query
    $exe = mysqli_query($con, $query);

    // Check for query execution error
    if (!$exe) {
        // If delete operation fails, return an error response
        http_response_code(500); // Internal Server Error
        echo json_encode(array('error' => 'Error deleting item from cart: ' . mysqli_error($con)));
        exit;
    }

    // If delete operation is successful
    echo json_encode(array('success' => 'Item deleted from cart successfully'));

    // Close database connection
    mysqli_close($con);
} else {
    // If user_id or game_id is not provided, return a bad request response
    http_response_code(400); // Bad request
    echo json_encode(array('error' => 'Missing user_id or game_id parameter'));
    exit;
}
?>
