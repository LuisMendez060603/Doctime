<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['correo']) || !isset($data['password']) || !isset($data['clave_cita'])) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos requeridos']);
    exit;
}

// Conectar a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión: ' . $conn->connect_error]);
    exit;
}

// Verificar que la cita pertenezca al paciente
$sql = "SELECT c.Clave_Cita 
        FROM cita c 
        INNER JOIN paciente p ON c.Clave_Paciente = p.Clave_Paciente 
        WHERE p.Correo = ? AND p.Password = ? AND c.Clave_Cita = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ssi", $data['correo'], $data['password'], $data['clave_cita']);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'No se encontró la cita o no tienes acceso a ella']);
    $stmt->close();
    $conn->close();
    exit;
}

$row = $result->fetch_assoc();
$claveCita = $row['Clave_Cita'];
$stmt->close();

// Obtener los datos de la consulta
$sql = "SELECT * FROM consultas WHERE Clave_Cita = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $claveCita);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => true, 'consulta' => null]);
} else {
    $consulta = $result->fetch_assoc();
    echo json_encode([
        'success' => true,
        'consulta' => [
            'clave_cita' => $consulta['Clave_Cita'],
            'sintomas' => $consulta['Sintomas'] ?? '',
            'diagnostico' => $consulta['Diagnostico'] ?? '',
            'tratamiento' => $consulta['Tratamiento'] ?? '',
            
        ]
    ]);
}

$stmt->close();
$conn->close();
?>
