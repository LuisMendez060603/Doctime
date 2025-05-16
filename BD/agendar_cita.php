<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['fecha'], $data['hora'], $data['clave_paciente'], $data['clave_profesional'])) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos']);
    exit();
}

$fecha = $data['fecha'];
$hora = $data['hora'];
$clave_paciente = intval($data['clave_paciente']);
$clave_profesional = intval($data['clave_profesional']);

// Conexión
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

// Verificar si ya hay una cita en la misma fecha, hora y con el mismo profesional
$check_sql = "SELECT * FROM cita WHERE Fecha = ? AND Hora = ? AND Clave_Profesional = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("ssi", $fecha, $hora, $clave_profesional);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows > 0) {
    // Ya existe una cita en ese horario con ese profesional
    echo json_encode(['success' => false, 'message' => 'Ya hay una cita agendada en esa hora con este profesional.']);
    $check_stmt->close();
    $conn->close();
    exit();
}

$check_stmt->close();

// Si no hay conflictos, agendar la cita
$sql = "INSERT INTO cita (Fecha, Hora, Clave_Paciente, Clave_Profesional) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssii", $fecha, $hora, $clave_paciente, $clave_profesional);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Cita agendada']);
} else {
    echo json_encode(['success' => false, 'message' => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
