<?php
include("dbconnection.php"); // Include your database connection file
$con = dbconnection(); // Establish database connection

// Check if search term is provided via GET request
if (isset($_GET['searchTerm'])) {
    $searchTerm = $_GET['searchTerm']; // Retrieve search term
    $searchTerm = mysqli_real_escape_string($con, $searchTerm); // Sanitize input

    // Construct SQL query to search for games by name
    $query = "SELECT * FROM game WHERE name LIKE '%$searchTerm%'";

    // Execute the query
    $exe = mysqli_query($con, $query);

    if ($exe) {
        $arr = []; // Initialize an empty array to store results

        // Fetch rows and add to array
        while ($row = mysqli_fetch_array($exe)) {
            $arr[] = $row;
        }

        // Output JSON response with search results
        header('Content-Type: application/json');
        echo json_encode($arr);
    } else {
        // Handle query execution error
        echo "Error executing query: " . mysqli_error($con);
    }
} else {
    // Handle case where search term is not provided
    echo "No search term provided";
}

// Close database connection
mysqli_close($con);
?>
