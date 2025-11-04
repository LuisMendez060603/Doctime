<?php
header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST');

// Leer JSON enviado desde Flutter
$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!isset($data['clave_cita'])) {
    echo json_encode(['success' => false, 'message' => 'Falta clave_cita']);
    exit();
}

$clave_cita = intval($data['clave_cita']);

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión a la base de datos']);
    exit();
}

// SQL: unir consultas, cita y paciente
$sql = "
SELECT 
    c.Clave_Cita,
    c.Sintomas,
    c.Diagnostico,
    c.Tratamiento,
    CONCAT(p.Nombre, ' ', p.Apellido) AS nombre_paciente
FROM consultas c
INNER JOIN cita ci ON c.Clave_Cita = ci.Clave_Cita
INNER JOIN paciente p ON ci.Clave_Paciente = p.Clave_Paciente
WHERE c.Clave_Cita = ?
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $clave_cita);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    $consulta = $result->fetch_assoc();
    echo json_encode([
        'success' => true,
        'consulta' => [
            'clave_cita' => $consulta['Clave_Cita'],
            'sintomas' => $consulta['Sintomas'],
            'diagnostico' => $consulta['Diagnostico'],
            'tratamiento' => $consulta['Tratamiento'],
            'nombre_paciente' => $consulta['nombre_paciente']
        ]
    ]);
} else {
    echo json_encode(['success' => true, 'consulta' => null]);
}

$stmt->close();
$conn->close();
?>
