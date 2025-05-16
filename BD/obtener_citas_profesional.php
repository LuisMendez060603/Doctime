<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['correo'])) {
    echo json_encode(['success' => false, 'message' => 'Falta el correo']);
    exit();
}

$correo = $data['correo'];

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

// Buscar clave del profesional por correo
$sql_clave = "SELECT Clave_Profesional FROM profesional WHERE Correo = ?";
$stmt_clave = $conn->prepare($sql_clave);
$stmt_clave->bind_param("s", $correo);
$stmt_clave->execute();
$result_clave = $stmt_clave->get_result();

if ($result_clave->num_rows == 0) {
    echo json_encode(['success' => false, 'message' => 'Profesional no encontrado']);
    exit();
}

$row = $result_clave->fetch_assoc();
$clave_profesional = $row['Clave_Profesional'];

// Obtener citas asociadas a ese profesional
$sql = "SELECT c.Clave_Cita, c.Fecha, c.Hora, p.Nombre AS Nombre_Paciente, c.Estado
        FROM cita c
        JOIN paciente p ON c.Clave_Paciente = p.Clave_Paciente
        WHERE c.Clave_Profesional = ?
        ORDER BY c.Fecha, c.Hora";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $clave_profesional);
$stmt->execute();
$result = $stmt->get_result();

$citas = [];
while ($row = $result->fetch_assoc()) {
    $citas[] = [
        'Clave_Cita' => $row['Clave_Cita'],
        'Fecha' => $row['Fecha'],
        'Hora' => $row['Hora'],
        'Nombre_Paciente' => $row['Nombre_Paciente'],
        'Estado' => $row['Estado']
    ];
}

echo json_encode(['success' => true, 'citas' => $citas]);


$stmt->close();
$conn->close();
?>
