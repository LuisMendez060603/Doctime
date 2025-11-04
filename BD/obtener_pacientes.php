<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "doctime";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Consulta de pacientes
$sql = "SELECT Nombre, Apellido, Telefono, Correo FROM paciente";
$result = $conn->query($sql);

$pacientes = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $pacientes[] = $row;
    }

    echo json_encode(["success" => true, "pacientes" => $pacientes]);
} else {
    echo json_encode(["success" => false, "message" => "No hay pacientes registrados"]);
}

$conn->close();
?>
