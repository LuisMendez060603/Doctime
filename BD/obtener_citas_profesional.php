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

// Verificar que el profesional existe (opcional, ya que solo hay uno)
$sql_prof = "SELECT Nombre, Especialidad FROM profesional WHERE Correo = ?";
$stmt_prof = $conn->prepare($sql_prof);
$stmt_prof->bind_param("s", $correo);
$stmt_prof->execute();
$result_prof = $stmt_prof->get_result();

if ($result_prof->num_rows == 0) {
    echo json_encode(['success' => false, 'message' => 'Profesional no encontrado']);
    $stmt_prof->close();
    $conn->close();
    exit();
}

$prof = $result_prof->fetch_assoc();
$nombre_profesional = $prof['Nombre'];
$especialidad = $prof['Especialidad'];
$stmt_prof->close();

// Obtener todas las citas (ya no se filtran por profesional)
$sql = "SELECT 
            c.Clave_Cita, 
            c.Fecha, 
            c.Hora, 
            p.Nombre AS Nombre_Paciente, 
            c.Estado
        FROM cita c
        JOIN paciente p ON c.Clave_Paciente = p.Clave_Paciente
        ORDER BY c.Fecha, c.Hora";

$result = $conn->query($sql);

$citas = [];
while ($row = $result->fetch_assoc()) {
    $citas[] = [
        'Clave_Cita' => $row['Clave_Cita'],
        'Fecha' => $row['Fecha'],
        'Hora' => $row['Hora'],
        'Nombre_Paciente' => $row['Nombre_Paciente'],
        'Estado' => $row['Estado'],
        'Nombre_Profesional' => $nombre_profesional,
        'Especialidad' => $especialidad
    ];
}

echo json_encode(['success' => true, 'citas' => $citas]);

$conn->close();
?>
