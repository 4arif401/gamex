<?php
include("dbconnection.php"); // Include your database connection file
$con = dbconnection(); // Establish database connection

// Set the content type to application/json
header('Content-Type: application/json');

try {
    // Check if all required fields are provided via POST request
    if (isset($_POST['user_id']) && isset($_POST['game_id']) && isset($_POST['game_name']) && isset($_POST['price'])) {
        $userId = mysqli_real_escape_string($con, $_POST['user_id']); // Sanitize input
        $gameId = mysqli_real_escape_string($con, $_POST['game_id']); // Sanitize input
        $gameName = mysqli_real_escape_string($con, $_POST['game_name']); // Sanitize input
        $gamePrice = mysqli_real_escape_string($con, $_POST['price']); // Sanitize input
        $imageURL = mysqli_real_escape_string($con, $_POST['imageurl']); // Sanitize input

        // Check if the game is already in the cart for the user
        $checkCartQuery = "SELECT * FROM cart WHERE user_id = '$userId' AND game_id = '$gameId'";
        $checkCartResult = mysqli_query($con, $checkCartQuery);

        // Check if the game is already owned by the user
        $checkOwnedQuery = "SELECT * FROM game_owned WHERE user_id = '$userId' AND game_id = '$gameId'";
        $checkOwnedResult = mysqli_query($con, $checkOwnedQuery);

        if (mysqli_num_rows($checkCartResult) > 0) {
            // If there is already a row with the same game_id and user_id in the cart, reject the process
            echo json_encode(array('status' => 'error', 'message' => 'The game is already in the cart'));
        } elseif (mysqli_num_rows($checkOwnedResult) > 0) {
            // If the game is already owned by the user, reject the process
            echo json_encode(array('status' => 'error', 'message' => 'The game is already owned by the user'));
        } else {
            // Insert data into cart table
            $insertQuery = "INSERT INTO cart (user_id, game_id, game_name, price, imageurl) VALUES ('$userId', '$gameId', '$gameName', '$gamePrice', '$imageURL')";
            $insertResult = mysqli_query($con, $insertQuery);

            if ($insertResult) {
                // Insert successful
                echo json_encode(array('status' => 'success', 'message' => 'Game added to cart successfully'));
            } else {
                // Handle query execution error
                echo json_encode(array('status' => 'error', 'message' => 'Error adding game to cart: ' . mysqli_error($con)));
            }
        }
    } else {
        // Handle case where all fields are not provided
        echo json_encode(array('status' => 'error', 'message' => 'User ID, game ID, game name, and price are required'));
    }
} catch (Exception $e) {
    echo json_encode(array('status' => 'error', 'message' => 'Exception: ' . $e->getMessage()));
}

// Close database connection
mysqli_close($con);
?>
