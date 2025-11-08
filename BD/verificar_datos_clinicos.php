<?php
// Conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "doctime";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["tiene_datos" => false, "mensaje" => "Conexión fallida: " . $conn->connect_error]));
}

// Obtener los datos enviados desde Flutter
$correo = $_POST['correo'] ?? '';
$passwordIngresado = $_POST['password'] ?? '';

if (empty($correo) || empty($passwordIngresado)) {
    echo json_encode(["tiene_datos" => false, "mensaje" => "Faltan datos."]);
    exit;
}

// 🔹 1️⃣ Buscar el paciente por correo
$queryPaciente = "SELECT Clave_Paciente, password FROM paciente WHERE correo = ?";
$stmt = $conn->prepare($queryPaciente);
$stmt->bind_param("s", $correo);
$stmt->execute();
$resultPaciente = $stmt->get_result();

if ($resultPaciente && $resultPaciente->num_rows > 0) {
    $rowPaciente = $resultPaciente->fetch_assoc();
    $clavePaciente = $rowPaciente['Clave_Paciente'];
    $passwordHash = $rowPaciente['password'];

    // 🔐 2️⃣ Verificar contraseña encriptada
    if (password_verify($passwordIngresado, $passwordHash)) {

        // 🔹 3️⃣ Buscar datos clínicos en la tabla datos_clinicos usando la clave del paciente
        $queryDatos = "SELECT tipo_sangre, alergias, enfermedades_cronicas, medicamentos_actuales, antecedentes_medicos 
                       FROM datos_clinicos 
                       WHERE Clave_Paciente = ?";
        $stmtDatos = $conn->prepare($queryDatos);
        $stmtDatos->bind_param("i", $clavePaciente);
        $stmtDatos->execute();
        $resultDatos = $stmtDatos->get_result();

        if ($resultDatos && $resultDatos->num_rows > 0) {
            $rowDatos = $resultDatos->fetch_assoc();

            // ✅ Verifica si hay datos clínicos registrados
            if (
                empty($rowDatos['tipo_sangre']) &&
                empty($rowDatos['alergias']) &&
                empty($rowDatos['enfermedades_cronicas']) &&
                empty($rowDatos['medicamentos_actuales']) &&
                empty($rowDatos['antecedentes_medicos'])
            ) {
                echo json_encode(["tiene_datos" => false, "mensaje" => "Campos vacíos"]);
            } else {
                echo json_encode(["tiene_datos" => true, "clave_paciente" => $clavePaciente]);
            }
        } else {
            // No tiene registro en la tabla datos_clinicos
            echo json_encode(["tiene_datos" => false, "mensaje" => "Sin registro de datos clínicos"]);
        }

        $stmtDatos->close();

    } else {
        // Contraseña incorrecta
        echo json_encode(["tiene_datos" => false, "mensaje" => "Contraseña incorrecta"]);
    }
} else {
    // No se encontró el correo
    echo json_encode(["tiene_datos" => false, "mensaje" => "Correo no encontrado"]);
}

$stmt->close();
$conn->close();
?>
