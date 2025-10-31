<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST');

// Leer los datos del cuerpo
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Verificar datos requeridos
if (!isset($data['clave_cita'])) {
    echo json_encode(['success' => false, 'message' => 'Falta clave_cita']);
    exit();
}

$clave_cita = intval($data['clave_cita']);

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

// Consultar la tabla consultas
$stmt = $conn->prepare("SELECT Clave_Cita, Sintomas, Diagnostico, Tratamiento FROM consultas WHERE Clave_Cita = ?");
$stmt->bind_param("i", $clave_cita);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $consulta = $result->fetch_assoc();
    echo json_encode([
        'success' => true,
        'consulta' => [
            'clave_cita' => $consulta['Clave_Cita'],
            'sintomas' => $consulta['Sintomas'],
            'diagnostico' => $consulta['Diagnostico'],
            'tratamiento' => $consulta['Tratamiento']
        ]
    ]);
} else {
    echo json_encode(['success' => true, 'consulta' => null]);
}

$stmt->close();
$conn->close();
?>
