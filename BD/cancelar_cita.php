<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['correo'], $data['password'], $data['fecha'], $data['hora'])) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos']);
    exit();
}

$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

$correo = $data['correo'];
$password = $data['password'];
$fecha = $data['fecha'];
$hora = $data['hora'];

$sql = "SELECT Clave_Paciente, Password FROM paciente WHERE Correo = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $correo);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'Paciente no encontrado']);
    exit();
}

$row = $result->fetch_assoc();
$clave_paciente = $row['Clave_Paciente'];
$hash_db = $row['Password'];

if (!password_verify($password, $hash_db)) {
    echo json_encode(['success' => false, 'message' => 'Contraseña incorrecta']);
    exit();
}

$stmt->close();

$update_sql = "UPDATE cita SET Estado = 'Cancelada' WHERE Clave_Paciente = ? AND Fecha = ? AND Hora = ?";
$update_stmt = $conn->prepare($update_sql);
$update_stmt->bind_param("iss", $clave_paciente, $fecha, $hora);

if ($update_stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al cancelar la cita']);
}

$update_stmt->close();
$conn->close();
?>
