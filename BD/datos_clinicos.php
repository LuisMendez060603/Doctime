<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");
header("Content-Type: application/json; charset=UTF-8");

// 🔹 Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "doctime");
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Error en la conexión: ' . $conn->connect_error]));
}

// 🔹 Recibir datos desde Flutter
$accion = $_POST['accion'] ?? '';
$correo = $_POST['correo'] ?? '';
$password = $_POST['password'] ?? '';
$clavePaciente = $_POST['clave_paciente'] ?? null; // ✅ Puede venir directo desde Flutter

// 🔹 Validar autenticación
if (empty($correo) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Faltan datos de autenticación"]);
    exit;
}

// 🔹 Si no se pasa clavePaciente, buscarla en la BD
if (!$clavePaciente) {
    $sql = "SELECT Clave_Paciente FROM paciente WHERE Correo = '$correo' AND password = '$password'";
    $result = $conn->query($sql);

    if ($result->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Paciente no encontrado"]);
        exit;
    }

    $row = $result->fetch_assoc();
    $clavePaciente = $row['Clave_Paciente'];
}

// 🔹 Acción: obtener datos clínicos
if ($accion === 'obtener') {
    $sqlDatos = "SELECT * FROM datos_clinicos WHERE Clave_Paciente = '$clavePaciente'";
    $resultDatos = $conn->query($sqlDatos);

    if ($resultDatos->num_rows > 0) {
        $datos = $resultDatos->fetch_assoc();
        $datos['Clave_Paciente'] = $clavePaciente; // 🔹 Añadir clave al array
        echo json_encode(["success" => true, "data" => $datos]);
    } else {
        // 🔹 Si no hay datos clínicos, aun así devolvemos la clave
        echo json_encode(["success" => false, "message" => "No hay datos clínicos registrados", "Clave_Paciente" => $clavePaciente]);
    }
    exit;
}

// 🔹 Acción: guardar o actualizar datos clínicos
if ($accion === 'guardar') {
    $tipo_sangre = $_POST['tipo_sangre'] ?? '';
    $alergias = $_POST['alergias'] ?? '';
    $enfermedades = $_POST['enfermedades_cronicas'] ?? '';
    $medicamentos = $_POST['medicamentos_actuales'] ?? '';
    $antecedentes = $_POST['antecedentes_medicos'] ?? '';
    $observaciones = $_POST['observaciones'] ?? '';
    $peso = $_POST['peso'] ?? null;
    $altura = $_POST['altura'] ?? null;
    $fumador = $_POST['fumador'] ?? 'No';
    $consumo_alcohol = $_POST['consumo_alcohol'] ?? 'No';

    // 🔹 Verificar si ya existen datos clínicos del paciente
    $sqlCheck = "SELECT * FROM datos_clinicos WHERE Clave_Paciente = '$clavePaciente'";
    $resultCheck = $conn->query($sqlCheck);

    if ($resultCheck->num_rows > 0) {
        // 🔹 Actualizar datos existentes
        $sqlUpdate = "UPDATE datos_clinicos SET
            tipo_sangre = '$tipo_sangre',
            alergias = '$alergias',
            enfermedades_cronicas = '$enfermedades',
            medicamentos_actuales = '$medicamentos',
            antecedentes_medicos = '$antecedentes',
            observaciones = '$observaciones',
            peso = " . ($peso !== null && $peso !== '' ? $peso : 'NULL') . ",
            altura = " . ($altura !== null && $altura !== '' ? $altura : 'NULL') . ",
            fumador = '$fumador',
            consumo_alcohol = '$consumo_alcohol',
            fecha_actualizacion = NOW()
            WHERE Clave_Paciente = '$clavePaciente'";

        if ($conn->query($sqlUpdate)) {
            echo json_encode(["success" => true, "message" => "Datos clínicos actualizados correctamente", "Clave_Paciente" => $clavePaciente]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al actualizar los datos clínicos", "Clave_Paciente" => $clavePaciente]);
        }
    } else {
        // 🔹 Insertar nuevos datos
        $sqlInsert = "INSERT INTO datos_clinicos (
            Clave_Paciente, tipo_sangre, alergias, enfermedades_cronicas,
            medicamentos_actuales, antecedentes_medicos, observaciones,
            peso, altura, fumador, consumo_alcohol
        ) VALUES (
            '$clavePaciente', '$tipo_sangre', '$alergias', '$enfermedades',
            '$medicamentos', '$antecedentes', '$observaciones',
            " . ($peso !== null && $peso !== '' ? $peso : 'NULL') . ",
            " . ($altura !== null && $altura !== '' ? $altura : 'NULL') . ",
            '$fumador', '$consumo_alcohol'
        )";

        if ($conn->query($sqlInsert)) {
            echo json_encode(["success" => true, "message" => "Datos clínicos registrados correctamente", "Clave_Paciente" => $clavePaciente]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al guardar los datos clínicos", "Clave_Paciente" => $clavePaciente]);
        }
    }

    exit;
}

// 🔹 Acción no válida
echo json_encode(["success" => false, "message" => "Acción no válida", "Clave_Paciente" => $clavePaciente]);
$conn->close();
?>
