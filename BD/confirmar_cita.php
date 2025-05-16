<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['clave_cita'])) {
    echo json_encode(['success' => false, 'message' => 'Falta clave de cita']);
    exit();
}

$clave_cita = $data['clave_cita'];

// Conectar a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

// Obtener el estado actual de la cita
$sql_estado = "SELECT Estado FROM cita WHERE Clave_Cita = ?";
$stmt_estado = $conn->prepare($sql_estado);
$stmt_estado->bind_param("i", $clave_cita);
$stmt_estado->execute();
$resultado = $stmt_estado->get_result();

$estado_actual = '';
if ($fila = $resultado->fetch_assoc()) {
    $estado_actual = $fila['Estado'];
}
$stmt_estado->close();

// Determinar el nuevo estado
if (strpos(strtolower($estado_actual), 'modificada') !== false) {
    $nuevo_estado = 'Modificada y Confirmada';
} else {
    $nuevo_estado = 'Confirmada';
}

// Actualizar el estado de la cita
$sql_actualizar = "UPDATE cita SET Estado = ? WHERE Clave_Cita = ?";
$stmt_actualizar = $conn->prepare($sql_actualizar);
$stmt_actualizar->bind_param("si", $nuevo_estado, $clave_cita);

if ($stmt_actualizar->execute()) {
    echo json_encode(['success' => true, 'message' => 'Cita confirmada']);
} else {
    echo json_encode(['success' => false, 'message' => 'No se pudo confirmar la cita']);
}

$stmt_actualizar->close();
$conn->close();
?>
