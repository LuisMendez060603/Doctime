<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Configuración de conexión
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "doctime";

// Conexión a la base de datos
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Obtener datos del cuerpo JSON
$data = json_decode(file_get_contents("php://input"), true);

// Validar que existan los datos necesarios
if (!empty($data["clave_paciente"]) && !empty($data["nombre"]) && !empty($data["apellido"]) && !empty($data["telefono"])) {
    $clave_paciente = $data["clave_paciente"];
    $nombre = $data["nombre"];
    $apellido = $data["apellido"];
    $telefono = $data["telefono"];

    // Preparar sentencia para actualizar
    $stmt = $conn->prepare("UPDATE paciente SET Nombre = ?, Apellido = ?, Telefono = ? WHERE Clave_Paciente = ?");
    $stmt->bind_param("sssi", $nombre, $apellido, $telefono, $clave_paciente);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Datos actualizados correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al actualizar los datos"]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Faltan datos obligatorios"]);
}

$conn->close();
?>
