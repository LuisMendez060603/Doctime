<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

// Verificar que se reciban los datos necesarios
if (!isset($data['fecha'], $data['hora'], $data['clave_paciente'])) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos']);
    exit();
}

$fecha = $data['fecha'];
$hora = $data['hora'];
$clave_paciente = intval($data['clave_paciente']);

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

// Verificar si ya existe una cita en la misma fecha y hora (sin profesional)
$check_sql = "SELECT * FROM cita WHERE Fecha = ? AND Hora = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("ss", $fecha, $hora);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows > 0) {
    echo json_encode(['success' => false, 'message' => 'Ya hay una cita agendada en esa hora.']);
    $check_stmt->close();
    $conn->close();
    exit();
}

$check_stmt->close();

// Insertar la nueva cita
$sql = "INSERT INTO cita (Fecha, Hora, Clave_Paciente, estado) VALUES (?, ?, ?, 'Activa')";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssi", $fecha, $hora, $clave_paciente);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Cita agendada correctamente']);
} else {
    echo json_encode(['success' => false, 'message' => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
