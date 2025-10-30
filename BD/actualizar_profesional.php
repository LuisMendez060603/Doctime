<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// Conexión DB
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "doctime";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Error de conexión: " . $conn->connect_error]);
    exit;
}

// Leer JSON
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);
if (!$data) {
    echo json_encode(["success" => false, "message" => "JSON inválido o vacío"]);
    $conn->close();
    exit;
}

// Campos requeridos (todos deben venir no vacíos)
if (empty($data["nombre"]) || empty($data["apellido"]) || empty($data["especialidad"]) || empty($data["telefono"]) || empty($data["direccion"])) {
    echo json_encode(["success" => false, "message" => "Faltan datos obligatorios"]);
    $conn->close();
    exit;
}

$nombre = trim($data["nombre"]);
$apellido = trim($data["apellido"]);
$especialidad = trim($data["especialidad"]);
$telefono = trim($data["telefono"]);
$direccion = trim($data["direccion"]);

// Actualizar por Clave_Profesional (entero) o por Correo (string)
if (!empty($data["clave_profesional"])) {
    $clave = intval($data["clave_profesional"]);
    $sql = "UPDATE profesional SET Nombre = ?, Apellido = ?, Especialidad = ?, Telefono = ?, Direccion = ? WHERE Clave_Profesional = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Error en prepare: " . $conn->error]);
        $conn->close();
        exit;
    }
    $stmt->bind_param("sssssi", $nombre, $apellido, $especialidad, $telefono, $direccion, $clave);
} else if (!empty($data["correo"])) {
    $correo = trim($data["correo"]);
    $sql = "UPDATE profesional SET Nombre = ?, Apellido = ?, Especialidad = ?, Telefono = ?, Direccion = ? WHERE Correo = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Error en prepare: " . $conn->error]);
        $conn->close();
        exit;
    }
    $stmt->bind_param("ssssss", $nombre, $apellido, $especialidad, $telefono, $direccion, $correo);
} else {
    echo json_encode(["success" => false, "message" => "No se proporcionó clave_profesional ni correo"]);
    $conn->close();
    exit;
}

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Datos del profesional actualizados correctamente"]);
} else {
    echo json_encode(["success" => false, "message" => "Error al actualizar: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>