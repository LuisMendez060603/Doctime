<?php
// Evitar que warnings/notices rompan la respuesta JSON
error_reporting(E_ALL);
ini_set('display_errors', '0'); // <<-- cambiar a 0
ini_set('log_errors', '1');
ini_set('error_log', __DIR__ . '/errores_php.log');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Error en la conexión con la base de datos: ' . $conn->connect_error]);
    exit;
}
$conn->set_charset('utf8mb4');

$accion = $_POST['accion'] ?? '';
$correo = trim($_POST['correo'] ?? '');
$password = trim($_POST['password'] ?? '');
$clavePaciente = $_POST['clave_paciente'] ?? null;

if ($accion !== 'guardar') {
    echo json_encode(['success' => false, 'message' => 'Este endpoint sólo acepta la acción "guardar".']);
    $conn->close();
    exit;
}

// Si no se proporciona clave_paciente, buscarla por correo/password
if (!$clavePaciente) {
    if (empty($correo) || empty($password)) {
        echo json_encode(["success" => false, "message" => "Faltan credenciales o clave_paciente"]);
        $conn->close();
        exit;
    }

    $sql = "SELECT Clave_Paciente, password FROM paciente WHERE Correo = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Error en consulta paciente: " . $conn->error]);
        $conn->close();
        exit;
    }
    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($result->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Paciente no encontrado"]);
        $conn->close();
        exit;
    }
    $row = $result->fetch_assoc();
    $stored = $row['password'];

    $auth_ok = false;
    if (!empty($stored)) {
        if (password_verify($password, $stored) || $password === $stored || $stored === md5($password)) {
            $auth_ok = true;
        }
    }
    if (!$auth_ok) {
        echo json_encode(["success" => false, "message" => "Contraseña incorrecta"]);
        $conn->close();
        exit;
    }
    $clavePaciente = $row['Clave_Paciente'];
}

// leer y normalizar campos
$fields = [
    // identificación opcional
    'nombre','edad','sexo','fecha_nacimiento','curp','telefono','direccion',
    // clínicos
    'tipo_sangre','alergias','enfermedades_cronicas','medicamentos_actuales','antecedentes_medicos','observaciones',
    'peso','altura','fumador','consumo_alcohol','diabetes','hipertension','cirugias_previas',
    'tabaquismo','alcoholismo','alimentacion','ejercicio','padre','madre','hermanos','padecimiento_actual'
];

$vals = [];
foreach ($fields as $f) {
    $vals[$f] = isset($_POST[$f]) ? trim($_POST[$f]) : '';
}

// Normalizar peso/altura a cadena vacía para usar NULLIF en SQL
$pesoVal = $vals['peso'] === '' ? '' : (string)$vals['peso'];
$alturaVal = $vals['altura'] === '' ? '' : (string)$vals['altura'];

// debug
error_log('datos_clinicos POST: ' . json_encode($_POST));

// Verificar que no exista ya registro para esta clave (este endpoint solo inserta)
$clavePaciente = (int)$clavePaciente;
$check = $conn->prepare("SELECT id_dato FROM datos_clinicos WHERE Clave_Paciente = ?");
if (!$check) {
    echo json_encode(['success' => false, 'message' => 'Error en prepare check: ' . $conn->error]);
    $conn->close();
    exit;
}
$check->bind_param("i", $clavePaciente);
$check->execute();
$resCheck = $check->get_result();
if ($resCheck->num_rows > 0) {
    // existe -> hacer UPDATE en lugar de bloquear
    $existing = $resCheck->fetch_assoc();
    $check->close();

    $sqlUpdate = "UPDATE datos_clinicos SET
        nombre = ?, edad = NULLIF(?, ''), sexo = ?, fecha_nacimiento = NULLIF(?, ''), curp = ?, telefono = ?, direccion = ?,
        tipo_sangre = ?, alergias = ?, enfermedades_cronicas = ?, medicamentos_actuales = ?, antecedentes_medicos = ?, observaciones = ?,
        peso = NULLIF(?, ''), altura = NULLIF(?, ''), fumador = ?, consumo_alcohol = ?, diabetes = ?, hipertension = ?, cirugias_previas = ?,
        tabaquismo = ?, alcoholismo = ?, alimentacion = ?, ejercicio = ?, padre = ?, madre = ?, hermanos = ?, padecimiento_actual = ?, fecha_actualizacion = NOW()
        WHERE Clave_Paciente = ?";

    $stmtUpd = $conn->prepare($sqlUpdate);
    if (!$stmtUpd) {
        error_log('prepare UPDATE error: ' . $conn->error);
        echo json_encode(["success" => false, "message" => "Error en prepare UPDATE: " . $conn->error]);
        $conn->close();
        exit;
    }

    $typesUpd = str_repeat('s', 28) . 'i';
    $paramsUpd = [
        // identificación
        $vals['nombre'],
        $vals['edad'],
        $vals['sexo'],
        $vals['fecha_nacimiento'],
        $vals['curp'],
        $vals['telefono'],
        $vals['direccion'],
        // clínicos
        $vals['tipo_sangre'],
        $vals['alergias'],
        $vals['enfermedades_cronicas'],
        $vals['medicamentos_actuales'],
        $vals['antecedentes_medicos'],
        $vals['observaciones'],
        $pesoVal,
        $alturaVal,
        $vals['fumador'],
        $vals['consumo_alcohol'],
        $vals['diabetes'],
        $vals['hipertension'],
        $vals['cirugias_previas'],
        $vals['tabaquismo'],
        $vals['alcoholismo'],
        $vals['alimentacion'],
        $vals['ejercicio'],
        $vals['padre'],
        $vals['madre'],
        $vals['hermanos'],
        $vals['padecimiento_actual'],
        // WHERE Clave_Paciente
        $clavePaciente
    ];

    // bind con referencias
    $bindUpd = array_merge([$typesUpd], refValues($paramsUpd));
    call_user_func_array([$stmtUpd, 'bind_param'], $bindUpd);

    $okUpd = $stmtUpd->execute();
    if (!$okUpd) {
        $stmtErr = $stmtUpd->error ?? '';
        $connErr = $conn->error ?? '';
        error_log('datos_clinicos UPDATE ERROR - stmt: ' . $stmtErr . ' | conn: ' . $connErr);
        echo json_encode([
            "success" => false,
            "message" => "Error al actualizar datos clínicos",
            "error_stmt" => $stmtErr,
            "error_conn" => $connErr
        ]);
        $stmtUpd->close();
        $conn->close();
        exit;
    }

    // devolver fila actualizada
    $stmtGet = $conn->prepare("SELECT * FROM datos_clinicos WHERE Clave_Paciente = ?");
    if ($stmtGet) {
        $stmtGet->bind_param("i", $clavePaciente);
        $stmtGet->execute();
        $resGet = $stmtGet->get_result();
        $row = $resGet ? $resGet->fetch_assoc() : [];
        $stmtGet->close();
    } else {
        $row = [];
    }

    echo json_encode([
        "success" => true,
        "message" => "Datos actualizados correctamente",
        "data" => $row
    ]);
    $stmtUpd->close();
    $conn->close();
    exit;
}

// Helper para pasar referencias a bind_param
function refValues($arr) {
    $refs = [];
    foreach ($arr as $key => $value) {
        $refs[$key] = &$arr[$key];
    }
    return $refs;
}

// Preparar INSERT (solo inserción)
$sql = "INSERT INTO datos_clinicos (
    Clave_Paciente, nombre, edad, sexo, fecha_nacimiento, curp, telefono, direccion,
    tipo_sangre, alergias, enfermedades_cronicas, medicamentos_actuales, antecedentes_medicos, observaciones,
    peso, altura, fumador, consumo_alcohol, diabetes, hipertension, cirugias_previas,
    tabaquismo, alcoholismo, alimentacion, ejercicio, padre, madre, hermanos, padecimiento_actual, fecha_creacion
) VALUES (?, ?, NULLIF(?, ''), ?, NULLIF(?, ''), ?, ?, ?, ?, ?, ?, ?, ?, ?, NULLIF(?, ''), NULLIF(?, ''), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    error_log('prepare INSERT error: ' . $conn->error);
    echo json_encode(["success" => false, "message" => "Error en prepare INSERT: " . $conn->error]);
    $conn->close();
    exit;
}

// tipos y parámetros: 1 entero + 28 strings
$types = 'i' . str_repeat('s', 28);
$params = [
    $clavePaciente,
    // identificación
    $vals['nombre'],
    $vals['edad'],
    $vals['sexo'],
    $vals['fecha_nacimiento'],
    $vals['curp'],
    $vals['telefono'],
    $vals['direccion'],
    // clínicos
    $vals['tipo_sangre'],
    $vals['alergias'],
    $vals['enfermedades_cronicas'],
    $vals['medicamentos_actuales'],
    $vals['antecedentes_medicos'],
    $vals['observaciones'],
    $pesoVal,
    $alturaVal,
    $vals['fumador'],
    $vals['consumo_alcohol'],
    $vals['diabetes'],
    $vals['hipertension'],
    $vals['cirugias_previas'],
    $vals['tabaquismo'],
    $vals['alcoholismo'],
    $vals['alimentacion'],
    $vals['ejercicio'],
    $vals['padre'],
    $vals['madre'],
    $vals['hermanos'],
    $vals['padecimiento_actual']
];

// bind con referencias
$bindParams = array_merge([$types], refValues($params));
call_user_func_array([$stmt, 'bind_param'], $bindParams);

$ok = $stmt->execute();

if ($ok) {
        // devolver la fila insertada
        $stmtGet = $conn->prepare("SELECT * FROM datos_clinicos WHERE Clave_Paciente = ?");
        if ($stmtGet) {
            $stmtGet->bind_param("i", $clavePaciente);
            $stmtGet->execute();
            $resGet = $stmtGet->get_result();
            $row = $resGet ? $resGet->fetch_assoc() : [];
            $stmtGet->close();
        } else {
            $row = [];
        }

        echo json_encode([
            "success" => true,
            "message" => "Datos guardados correctamente",
            "data" => $row
        ]);
    } else {
    $stmtErr = $stmt->error ?? '';
    $connErr = $conn->error ?? '';
    error_log('datos_clinicos INSERT ERROR - stmt: ' . $stmtErr . ' | conn: ' . $connErr);
    echo json_encode([
        "success" => false,
        "message" => "Error al insertar datos clínicos",
        "error_stmt" => $stmtErr,
        "error_conn" => $connErr
    ]);
}

$stmt->close();
$conn->close();
?>
