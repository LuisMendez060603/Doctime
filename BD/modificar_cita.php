<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['correo'], $data['password'], $data['clave_cita'], $data['nueva_fecha'], $data['nueva_hora'])) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos']);
    exit();
}

$correo = $data['correo'];
$password = $data['password'];
$clave_cita = $data['clave_cita'];
$nueva_fecha = $data['nueva_fecha'];
$nueva_hora = $data['nueva_hora'];

$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error de conexión']);
    exit();
}

// Verificar el correo y la contraseña del paciente
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

if (!password_verify($password, $hash_db)) {
    echo json_encode(['success' => false, 'message' => 'Contraseña incorrecta']);
    exit();
}

$stmt_paciente->close();

// Verificar que la cita pertenece al paciente
$sql_cita = "SELECT Clave_Cita, Clave_Paciente FROM cita WHERE Clave_Cita = ?";
$stmt_cita = $conn->prepare($sql_cita);
$stmt_cita->bind_param("i", $clave_cita);
$stmt_cita->execute();
$result_cita = $stmt_cita->get_result();

if ($result_cita->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'Cita no encontrada']);
    exit();
}

$cita = $result_cita->fetch_assoc();
if ($cita['Clave_Paciente'] !== $clave_paciente) {
    echo json_encode(['success' => false, 'message' => 'La cita no pertenece a este paciente']);
    exit();
}

// ✅ Actualizar la cita, incluyendo el estado como 'modificada'
$sql_actualizar = "UPDATE cita SET Fecha = ?, Hora = ?, Estado = 'modificada' WHERE Clave_Cita = ?";
$stmt_actualizar = $conn->prepare($sql_actualizar);
$stmt_actualizar->bind_param("ssi", $nueva_fecha, $nueva_hora, $clave_cita);

if ($stmt_actualizar->execute()) {
    echo json_encode(['success' => true, 'message' => 'Cita modificada exitosamente']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al modificar la cita']);
}

$stmt_actualizar->close();
$stmt_cita->close();
$conn->close();
?>
