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

// Verificar que el profesional existe
$sql_prof = "SELECT Clave_Profesional FROM profesional WHERE Correo = ?";
$stmt_prof = $conn->prepare($sql_prof);
$stmt_prof->bind_param("s", $correo);
$stmt_prof->execute();
$result_prof = $stmt_prof->get_result();

if ($result_prof->num_rows == 0) {
    echo json_encode(['success' => false, 'message' => 'Profesional no encontrado']);
    exit();
}

// Obtener todas las citas sin filtrar por profesional
$sql = "SELECT 
            c.Clave_Cita, 
            c.Fecha, 
            c.Hora, 
            p.Nombre AS Nombre_Paciente, 
            c.Estado,
            c.Clave_Profesional,
            prof.Nombre AS Nombre_Profesional,
            prof.Especialidad
        FROM cita c
        JOIN paciente p ON c.Clave_Paciente = p.Clave_Paciente
        JOIN profesional prof ON c.Clave_Profesional = prof.Clave_Profesional
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
        'Clave_Profesional' => $row['Clave_Profesional'],
        'Nombre_Profesional' => $row['Nombre_Profesional'],
        'Especialidad' => $row['Especialidad']
    ];
}

echo json_encode(['success' => true, 'citas' => $citas]);

$conn->close();
?>
