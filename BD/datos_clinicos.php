<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");
header("Content-Type: application/json; charset=UTF-8");

// 🔹 Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Error en la conexión con la base de datos.']));
}

// 🔹 Recibir datos desde Flutter
$accion = $_POST['accion'] ?? '';
$correo = trim($_POST['correo'] ?? '');
$password = trim($_POST['password'] ?? '');
$clavePaciente = $_POST['clave_paciente'] ?? null;

// 🔹 Validar autenticación
if (empty($correo) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Faltan datos de autenticación"]);
    exit;
}

// 🔹 Buscar clave del paciente si no se pasó directamente
if (!$clavePaciente) {
    $sql = "SELECT Clave_Paciente, password FROM paciente WHERE Correo = '$correo'";
    $result = $conn->query($sql);

    if ($result->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Paciente no encontrado"]);
        exit;
    }

    $row = $result->fetch_assoc();
    if (!password_verify($password, $row['password'])) {
        echo json_encode(["success" => false, "message" => "Contraseña incorrecta"]);
        exit;
    }

    $clavePaciente = $row['Clave_Paciente'];
}

// 🔹 Acción: obtener datos clínicos
if ($accion === 'obtener') {
    $sql = "SELECT tipo_sangre, alergias, enfermedades_cronicas, medicamentos_actuales,
                   antecedentes_medicos, observaciones, peso, altura, fumador, consumo_alcohol
            FROM datos_clinicos WHERE Clave_Paciente = '$clavePaciente'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        echo json_encode(["success" => true, "data" => $result->fetch_assoc()]);
    } else {
        echo json_encode(["success" => false, "message" => "No hay datos clínicos registrados"]);
    }
    exit;
}

// 🔹 Acción: guardar o actualizar datos clínicos
if ($accion === 'guardar') {
    $campos = [
        'tipo_sangre', 'alergias', 'enfermedades_cronicas', 'medicamentos_actuales',
        'antecedentes_medicos', 'observaciones', 'peso', 'altura', 'fumador', 'consumo_alcohol'
    ];

    $valores = [];
    foreach ($campos as $campo) {
        $valores[$campo] = $conn->real_escape_string($_POST[$campo] ?? '');
    }

    // Verificar si ya existen datos
    $check = $conn->query("SELECT id_dato FROM datos_clinicos WHERE Clave_Paciente = '$clavePaciente'");
    if ($check->num_rows > 0) {
        // Actualizar
        $sql = "UPDATE datos_clinicos SET
            tipo_sangre = '{$valores['tipo_sangre']}',
            alergias = '{$valores['alergias']}',
            enfermedades_cronicas = '{$valores['enfermedades_cronicas']}',
            medicamentos_actuales = '{$valores['medicamentos_actuales']}',
            antecedentes_medicos = '{$valores['antecedentes_medicos']}',
            observaciones = '{$valores['observaciones']}',
            peso = NULLIF('{$valores['peso']}', ''),
            altura = NULLIF('{$valores['altura']}', ''),
            fumador = NULLIF('{$valores['fumador']}', ''),
            consumo_alcohol = NULLIF('{$valores['consumo_alcohol']}', ''),
            fecha_actualizacion = NOW()
            WHERE Clave_Paciente = '$clavePaciente'";
        $ok = $conn->query($sql);
        echo json_encode(["success" => $ok, "message" => $ok ? "Datos clínicos actualizados correctamente" : "Error al actualizar datos clínicos"]);
    } else {
        // Insertar
        $sql = "INSERT INTO datos_clinicos (
            Clave_Paciente, tipo_sangre, alergias, enfermedades_cronicas, medicamentos_actuales,
            antecedentes_medicos, observaciones, peso, altura, fumador, consumo_alcohol
        ) VALUES (
            '$clavePaciente', '{$valores['tipo_sangre']}', '{$valores['alergias']}',
            '{$valores['enfermedades_cronicas']}', '{$valores['medicamentos_actuales']}',
            '{$valores['antecedentes_medicos']}', '{$valores['observaciones']}',
            NULLIF('{$valores['peso']}', ''), NULLIF('{$valores['altura']}', ''),
            NULLIF('{$valores['fumador']}', ''), NULLIF('{$valores['consumo_alcohol']}', '')
        )";
        $ok = $conn->query($sql);
        echo json_encode(["success" => $ok, "message" => $ok ? "Datos clínicos guardados correctamente" : "Error al guardar datos clínicos"]);
    }
    exit;
}

echo json_encode(["success" => false, "message" => "Acción no válida"]);
$conn->close();
?>
