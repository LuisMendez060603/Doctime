<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

// Verificar datos obligatorios
if (!isset($data['correo'], $data['password'])) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos']);
    exit();
}

$correo = $data['correo'];
$password = $data['password'];

// Conexión
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

// Buscar paciente
$sql_paciente = "SELECT Clave_Paciente, Password FROM paciente WHERE Correo = ?";
$stmt_paciente = $conn->prepare($sql_paciente);
$stmt_paciente->bind_param("s", $correo);
$stmt_paciente->execute();
$result_paciente = $stmt_paciente->get_result();

if ($result_paciente->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'Paciente no encontrado']);
    exit();
}

$row = $result_paciente->fetch_assoc();
$clave_paciente = $row['Clave_Paciente'];
$hash_db = $row['Password'];

// Verificar contraseña
if (!password_verify($password, $hash_db)) {
    echo json_encode(['success' => false, 'message' => 'Contraseña incorrecta']);
    exit();
}

$stmt_paciente->close();

// Obtener citas del paciente (ya sin Clave_Profesional)
$sql_citas = "SELECT Clave_Cita, Fecha, Hora, Estado FROM cita WHERE Clave_Paciente = ? ORDER BY Fecha DESC, Hora DESC";
$stmt_citas = $conn->prepare($sql_citas);
$stmt_citas->bind_param("i", $clave_paciente);
$stmt_citas->execute();
$result_citas = $stmt_citas->get_result();

$citas = [];
while ($row = $result_citas->fetch_assoc()) {
    $citas[] = [
        'clave_cita' => $row['Clave_Cita'],
        'fecha' => $row['Fecha'],
        'hora' => $row['Hora'],
        'profesional' => 'Profesional Independiente', // Texto fijo ya que solo hay uno
        'estado' => $row['Estado'] ?? 'Activa'
    ];
}

echo json_encode(['success' => true, 'citas' => $citas]);

$stmt_citas->close();
$conn->close();
?>
