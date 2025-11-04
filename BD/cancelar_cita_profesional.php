<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['clave_cita'])) {
    echo json_encode(['success' => false, 'message' => 'Falta la clave de la cita']);
    exit();
}

$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión con la base de datos']);
    exit();
}

$clave_cita = $data['clave_cita'];

$update_sql = "UPDATE cita SET Estado = 'Cancelada' WHERE Clave_Cita = ?";
$stmt = $conn->prepare($update_sql);
$stmt->bind_param("i", $clave_cita);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Cita cancelada correctamente']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al cancelar la cita']);
}

$stmt->close();
$conn->close();
?>
