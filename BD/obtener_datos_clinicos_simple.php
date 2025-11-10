<?php
error_reporting(E_ALL);
ini_set('display_errors', '0');
ini_set('log_errors', '1');
ini_set('error_log', __DIR__ . '/errores_php.log');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error BD: ' . $conn->connect_error]);
    exit;
}
$conn->set_charset('utf8mb4');

// Leer entrada JSON o form-data
$raw = file_get_contents('php://input');
$input = json_decode($raw, true);

$clavePaciente = null;
if (is_array($input) && !empty($input['clave_paciente'])) {
    $clavePaciente = trim($input['clave_paciente']);
} elseif (!empty($_POST['clave_paciente'])) {
    $clavePaciente = trim($_POST['clave_paciente']);
}

if ($clavePaciente === null || $clavePaciente === '') {
    echo json_encode(['success' => false, 'message' => 'Falta clave_paciente']);
    $conn->close();
    exit;
}

// Determinar tipo de bind (int si es totalmente dígitos)
$paramType = ctype_digit($clavePaciente) ? 'i' : 's';
if ($paramType === 'i') $clavePaciente = (int)$clavePaciente;

$sql = "SELECT id_dato, Clave_Paciente, nombre, edad, sexo, fecha_nacimiento, curp, telefono, direccion,
    tipo_sangre, alergias, enfermedades_cronicas, medicamentos_actuales, antecedentes_medicos, observaciones,
    peso, altura, fumador, consumo_alcohol, diabetes, hipertension, cirugias_previas,
    tabaquismo, alcoholismo, alimentacion, ejercicio, padre, madre, hermanos, padecimiento_actual,
    fecha_creacion, fecha_actualizacion
    FROM datos_clinicos WHERE Clave_Paciente = ? LIMIT 1";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(['success' => false, 'message' => 'Error prepare: ' . $conn->error]);
    $conn->close();
    exit;
}

$stmt->bind_param($paramType, $clavePaciente);
$stmt->execute();
$res = $stmt->get_result();

if ($res && $res->num_rows > 0) {
    $data = $res->fetch_assoc();

    // Asegurar claves (opcional): rellenar con empty string si falta
    $expected = [
        'id_dato','Clave_Paciente','nombre','edad','sexo','fecha_nacimiento','curp','telefono','direccion',
        'tipo_sangre','alergias','enfermedades_cronicas','medicamentos_actuales','antecedentes_medicos','observaciones',
        'peso','altura','fumador','consumo_alcohol','diabetes','hipertension','cirugias_previas',
        'tabaquismo','alcoholismo','alimentacion','ejercicio','padre','madre','hermanos','padecimiento_actual',
        'fecha_creacion','fecha_actualizacion'
    ];
    foreach ($expected as $k) {
        if (!array_key_exists($k, $data)) $data[$k] = '';
    }

    echo json_encode(['success' => true, 'data' => $data]);
} else {
    echo json_encode(['success' => false, 'message' => 'No se encontraron datos clínicos para esa clave']);
}

$stmt->close();
$conn->close();