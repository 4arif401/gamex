<?php
include("dbconnection.php"); // Include your database connection file
$con = dbconnection(); // Establish database connection

// Check if user_id and game_id are sent via POST
if (isset($_POST['user_id'], $_POST['game_id'])) {
    $userId = mysqli_real_escape_string($con, $_POST['user_id']);
    $gameId = mysqli_real_escape_string($con, $_POST['game_id']);

    // Construct SELECT query to fetch cart item
    $selectQuery = "SELECT game_id, user_id, game_name, price, imageurl FROM cart WHERE user_id = '$userId' AND game_id = '$gameId'";
    $selectResult = mysqli_query($con, $selectQuery);

    // Check if cart item exists
    if ($selectResult && mysqli_num_rows($selectResult) > 0) {
        // Fetch the cart item data
        $cartItem = mysqli_fetch_assoc($selectResult);

        // Extract data from cart item
        $gameId = $cartItem['game_id'];
        $userId = $cartItem['user_id'];
        $gameName = $cartItem['game_name'];
        $price = $cartItem['price'];
        $imageUrl = $cartItem['imageurl'];

        // Insert into game_owned table
        $insertQuery = "INSERT INTO game_owned (user_id, game_id, game_name, price, imageurl) 
                        VALUES ('$userId', '$gameId', '$gameName', '$price', '$imageUrl')";

        // Execute the INSERT query
        $insertExe = mysqli_query($con, $insertQuery);

        // Check for query execution error
        if ($insertExe) {
            // If insert operation is successful, delete from cart
            $deleteQuery = "DELETE FROM cart WHERE user_id = '$userId' AND game_id = '$gameId'";
            $deleteExe = mysqli_query($con, $deleteQuery);

            // Check for delete operation error
            if ($deleteExe) {
                // Success response
                echo json_encode(array('status' => 'success', 'message' => 'Item transferred to game_owned successfully'));
            } else {
                // If delete operation fails, return an error response
                http_response_code(500); // Internal Server Error
                echo json_encode(array('error' => 'Error deleting item from cart after transfer: ' . mysqli_error($con)));
                exit;
            }
        } else {
            // If insert operation fails, return an error response
            http_response_code(500); // Internal Server Error
            echo json_encode(array('error' => 'Error transferring item to game_owned: ' . mysqli_error($con)));
            exit;
        }
    } else {
        // If cart item does not exist, return a not found response
        http_response_code(404); // Not Found
        echo json_encode(array('error' => 'Cart item not found'));
        exit;
    }

    // Close database connection
    mysqli_close($con);

} else {
    // If user_id or game_id is not provided, return a bad request response
    http_response_code(400); // Bad request
    echo json_encode(array('error' => 'Missing user_id or game_id parameter'));
    exit;
}
?>
