<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['fecha'], $data['clave_profesional'])) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos']);
    exit();
}

$fecha = $data['fecha'];
$clave_profesional = intval($data['clave_profesional']);

// Conexión
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

// Horarios posibles
$horasPermitidas = [
    "08:00 AM", "09:00 AM", "10:00 AM", "11:00 AM",
    "12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM",
];

$ocupados = [];
$check_sql = "SELECT Hora FROM cita WHERE Fecha = ? AND Clave_Profesional = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("si", $fecha, $clave_profesional);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

while ($row = $check_result->fetch_assoc()) {
    $hora = date("h:i A", strtotime($row['Hora']));
    $ocupados[] = $hora;
}

$check_stmt->close();
$conn->close();

// Filtrar las horas ocupadas de la lista de horas permitidas
$disponibles = array_diff($horasPermitidas, $ocupados);

echo json_encode(['success' => true, 'horas_disponibles' => array_values($disponibles)]);
?>
