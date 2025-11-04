<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

// Verificar que se reciba la fecha
if (!isset($data['fecha'])) {
    echo json_encode(['success' => false, 'message' => 'Falta la fecha']);
    exit();
}

$fecha = $data['fecha'];

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

// Consultar horas ya ocupadas en esa fecha
$check_sql = "SELECT Hora FROM cita WHERE Fecha = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("s", $fecha);
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

// Devolver resultado
echo json_encode(['success' => true, 'horas_disponibles' => array_values($disponibles)]);
?>
