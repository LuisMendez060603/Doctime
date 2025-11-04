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

// Campos requeridos
if (empty($data["nombre"]) || empty($data["apellido"]) || !isset($data["telefono"])) {
    echo json_encode(["success" => false, "message" => "Faltan datos obligatorios"]);
    $conn->close();
    exit;
}

$nombre = $data["nombre"];
$apellido = $data["apellido"];
$telefono = $data["telefono"];

// Si el cliente envía clave_paciente (entero) actualizar por Clave_Paciente,
// si envía correo actualizar por Correo. Se acepta cualquiera de los dos.
if (!empty($data["clave_paciente"])) {
    $clave = intval($data["clave_paciente"]);
    $sql = "UPDATE paciente SET Nombre = ?, Apellido = ?, Telefono = ? WHERE Clave_Paciente = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Error en prepare: " . $conn->error]);
        $conn->close();
        exit;
    }
    $stmt->bind_param("sssi", $nombre, $apellido, $telefono, $clave);
} else if (!empty($data["correo"])) {
    $correo = $data["correo"];
    $sql = "UPDATE paciente SET Nombre = ?, Apellido = ?, Telefono = ? WHERE Correo = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Error en prepare: " . $conn->error]);
        $conn->close();
        exit;
    }
    $stmt->bind_param("ssss", $nombre, $apellido, $telefono, $correo);
} else {
    echo json_encode(["success" => false, "message" => "No se proporcionó clave_paciente ni correo"]);
    $conn->close();
    exit;
}

if ($stmt->execute()) {
    // affected_rows puede ser 0 si los datos son iguales a los existentes
    echo json_encode(["success" => true, "message" => "Datos actualizados correctamente"]);
} else {
    echo json_encode(["success" => false, "message" => "Error al actualizar: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
