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
    echo json_encode(['success'=>false,'message'=>'Error BD: '.$conn->connect_error]);
    exit;
}
$conn->set_charset('utf8mb4');

$correo = trim($_POST['correo'] ?? '');
$password = trim($_POST['password'] ?? '');
$clavePaciente = $_POST['clave_paciente'] ?? null;

if (!$clavePaciente) {
    if (empty($correo) || empty($password)) {
        echo json_encode(['success'=>false,'message'=>'Debe enviar correo+password o clave_paciente']);
        $conn->close();
        exit;
    }
    // buscar Clave_Paciente en tabla paciente
    $stmt = $conn->prepare("SELECT Clave_Paciente, password FROM paciente WHERE Correo = ?");
    if (!$stmt) { echo json_encode(['success'=>false,'message'=>'Error prepare paciente']); $conn->close(); exit; }
    $stmt->bind_param("s",$correo);
    $stmt->execute();
    $res = $stmt->get_result();
    if ($res->num_rows === 0) { echo json_encode(['success'=>false,'message'=>'Usuario no encontrado']); $stmt->close(); $conn->close(); exit; }
    $row = $res->fetch_assoc();
    $stored = $row['password'];
    $clavePaciente = $row['Clave_Paciente'];
    $stmt->close();
    // validar password simple (ajusta según tu hashing)
    if ($stored !== $password && !password_verify($password, $stored)) {
        echo json_encode(['success'=>false,'message'=>'Credenciales incorrectas']);
        $conn->close();
        exit;
    }
}

$clavePaciente = (int)$clavePaciente;
$sql = "SELECT id_dato, Clave_Paciente, nombre, edad, sexo, fecha_nacimiento, curp, telefono, direccion,
    tipo_sangre, alergias, enfermedades_cronicas, medicamentos_actuales, antecedentes_medicos, observaciones,
    peso, altura, fumador, consumo_alcohol, diabetes, hipertension, cirugias_previas,
    tabaquismo, alcoholismo, alimentacion, ejercicio, padre, madre, hermanos, padecimiento_actual,
    fecha_creacion, fecha_actualizacion
    FROM datos_clinicos WHERE Clave_Paciente = ? LIMIT 1";
$stmt = $conn->prepare($sql);
if (!$stmt) { echo json_encode(['success'=>false,'message'=>'Error prepare select: '.$conn->error]); $conn->close(); exit; }
$stmt->bind_param("i",$clavePaciente);
$stmt->execute();
$res = $stmt->get_result();
if ($res && $res->num_rows > 0) {
    $data = $res->fetch_assoc();
    // asegurar que existan todas las claves
    $defaults = [
        'id_dato' => null,
        'Clave_Paciente' => $clavePaciente,
        'nombre' => '',
        'edad' => '',
        'sexo' => '',
        'fecha_nacimiento' => '',
        'curp' => '',
        'telefono' => '',
        'direccion' => '',
        'tipo_sangre' => '',
        'alergias' => '',
        'enfermedades_cronicas' => '',
        'medicamentos_actuales' => '',
        'antecedentes_medicos' => '',
        'observaciones' => '',
        'peso' => '',
        'altura' => '',
        'fumador' => '',
        'consumo_alcohol' => '',
        'diabetes' => '',
        'hipertension' => '',
        'cirugias_previas' => '',
        'tabaquismo' => '',
        'alcoholismo' => '',
        'alimentacion' => '',
        'ejercicio' => '',
        'padre' => '',
        'madre' => '',
        'hermanos' => '',
        'padecimiento_actual' => '',
        'fecha_creacion' => '',
        'fecha_actualizacion' => ''
    ];
    foreach ($defaults as $k => $v) {
        if (!array_key_exists($k, $data)) $data[$k] = $v;
    }
    echo json_encode(['success' => true, 'data' => $data]);
} else {
    // devolver objeto con todos los campos vacíos para pre‑rellenar el formulario
    $data = [
        'id_dato' => null,
        'Clave_Paciente' => $clavePaciente,
        'nombre' => '',
        'edad' => '',
        'sexo' => '',
        'fecha_nacimiento' => '',
        'curp' => '',
        'telefono' => '',
        'direccion' => '',
        'tipo_sangre' => '',
        'alergias' => '',
        'enfermedades_cronicas' => '',
        'medicamentos_actuales' => '',
        'antecedentes_medicos' => '',
        'observaciones' => '',
        'peso' => '',
        'altura' => '',
        'fumador' => '',
        'consumo_alcohol' => '',
        'diabetes' => '',
        'hipertension' => '',
        'cirugias_previas' => '',
        'tabaquismo' => '',
        'alcoholismo' => '',
        'alimentacion' => '',
        'ejercicio' => '',
        'padre' => '',
        'madre' => '',
        'hermanos' => '',
        'padecimiento_actual' => '',
        'fecha_creacion' => '',
        'fecha_actualizacion' => ''
    ];
    echo json_encode(['success' => true, 'data' => $data]);
}
$stmt->close();
$conn->close();