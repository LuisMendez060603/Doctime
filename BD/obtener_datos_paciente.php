<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

// Leer datos del cuerpo de la solicitud
$data = json_decode(file_get_contents("php://input"), true);

// Verificar que se haya enviado la clave de cita
if (!isset($data['clave_cita'])) {
    echo json_encode(['success' => false, 'message' => 'Falta clave de cita']);
    exit();
}

$clave_cita = $data['clave_cita'];

// Conectar a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión a la base de datos']);
    exit();
}

// Consulta para obtener los datos del paciente asociado a la cita
$sql = "SELECT p.Nombre, p.Apellido, p.Telefono, p.Correo
        FROM paciente p
        JOIN cita c ON p.Clave_Paciente = c.Clave_Paciente
        WHERE c.Clave_Cita = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $clave_cita);
$stmt->execute();

$result = $stmt->get_result();
if ($row = $result->fetch_assoc()) {
    echo json_encode(['success' => true, 'paciente' => $row]);
} else {
    echo json_encode(['success' => false, 'message' => 'Paciente no encontrado']);
}

$stmt->close();
$conn->close();
?>
