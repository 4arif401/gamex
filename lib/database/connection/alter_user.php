<?php
include("dbconnection.php"); // Include your database connection file
$con = dbconnection(); // Establish database connection

// Function to fetch the current password for validation
function getCurrentPassword($con, $userId) {
    $query = "SELECT password FROM user WHERE user_id = '$userId'";
    $result = mysqli_query($con, $query);
    if ($result) {
        $row = mysqli_fetch_assoc($result);
        return $row['password'];
    }
    return null;
}

// Check if the required POST parameters are set
if (isset($_POST['user_id']) && isset($_POST['display_name']) && isset($_POST['email']) && isset($_POST['phone']) && isset($_POST['password'])) {
    $userId = mysqli_real_escape_string($con, $_POST['user_id']);
    $displayName = mysqli_real_escape_string($con, $_POST['display_name']);
    $email = mysqli_real_escape_string($con, $_POST['email']);
    $phone = mysqli_real_escape_string($con, $_POST['phone']);
    $password = mysqli_real_escape_string($con, $_POST['password']);

    // Fetch the current password from the database
    $currentPassword = getCurrentPassword($con, $userId);

    if ($currentPassword === $password) {
        // Password matches, proceed to update the user details
        $updateQuery = "UPDATE user SET display_name = '$displayName', email = '$email', phone = '$phone' WHERE user_id = '$userId'";
        $updateResult = mysqli_query($con, $updateQuery);

        if ($updateResult) {
            echo json_encode(array('status' => 'success', 'message' => 'User details updated successfully.'));
        } else {
            echo json_encode(array('status' => 'error', 'message' => 'Failed to update user details.'));
        }
    } else {
        // Password does not match
        echo json_encode(array('status' => 'error', 'message' => 'Incorrect password.'));
    }

    // Close database connection
    mysqli_close($con);
} else {
    // If required parameters are not provided, return an error response
    http_response_code(400); // Bad request
    echo json_encode(array('status' => 'error', 'message' => 'Missing required parameters.'));
    exit;
}
?>