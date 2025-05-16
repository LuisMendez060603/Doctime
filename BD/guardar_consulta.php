<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['clave_cita'], $data['sintomas'], $data['diagnostico'], $data['tratamiento'])) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos']);
    exit();
}

$claveCita = $data['clave_cita'];
$sintomas = $data['sintomas'];
$diagnostico = $data['diagnostico'];
$tratamiento = $data['tratamiento'];

// Conectar a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión: ' . $conn->connect_error]);
    exit();
}

// Usar sentencia preparada con ON DUPLICATE KEY UPDATE
$sql = "INSERT INTO consultas (Clave_Cita, Sintomas, Diagnostico, Tratamiento)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
        Sintomas = VALUES(Sintomas),
        Diagnostico = VALUES(Diagnostico),
        Tratamiento = VALUES(Tratamiento)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("isss", $claveCita, $sintomas, $diagnostico, $tratamiento);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Consulta guardada']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al guardar: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
