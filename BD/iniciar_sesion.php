<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Configuración de conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "doctime";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Leer datos enviados desde Flutter
$data = json_decode(file_get_contents("php://input"), true);

// Asegurarse de que los datos necesarios estén presentes
if (!empty($data["correo"]) && !empty($data["password"])) {
    $correo = $data["correo"];
    $password = $data["password"];

    // Buscar en la tabla de pacientes (ya sin Historial_Citas)
    $sql_paciente = "SELECT correo, password, Nombre, Apellido, Telefono, Clave_Paciente FROM paciente WHERE correo = ?";
    $stmt = $conn->prepare($sql_paciente);
    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $result_paciente = $stmt->get_result();

    if ($result_paciente->num_rows > 0) {
        $user = $result_paciente->fetch_assoc();

        if (password_verify($password, $user["password"])) {
            session_start(); // Iniciar sesión
            $_SESSION['correo'] = $user["correo"];
            $_SESSION['tipo_usuario'] = 'paciente';
            $_SESSION['clave_paciente'] = $user["Clave_Paciente"]; // Guardar la clave del paciente en la sesión

            echo json_encode([
                "success" => true,
                "tipo_usuario" => "paciente",
                "message" => "Inicio de sesión exitoso (paciente)",
                "correo" => $user["correo"],
                "nombre" => $user["Nombre"],
                "apellido" => $user["Apellido"],
                "telefono" => $user["Telefono"],
                "clave_paciente" => $user["Clave_Paciente"]
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Contraseña incorrecta"]);
        }
    } else {
        // Buscar en la tabla de profesionales
        $sql_profesional = "SELECT correo, password, Nombre, Apellido, Especialidad, Telefono, Direccion FROM profesional WHERE correo = ?";
        $stmt = $conn->prepare($sql_profesional);
        $stmt->bind_param("s", $correo);
        $stmt->execute();
        $result_profesional = $stmt->get_result();

        if ($result_profesional->num_rows > 0) {
            $user = $result_profesional->fetch_assoc();

            if (password_verify($password, $user["password"])) {
                session_start(); // Iniciar sesión
                $_SESSION['correo'] = $user["correo"];
                $_SESSION['tipo_usuario'] = 'profesional';

                echo json_encode([
                    "success" => true,
                    "tipo_usuario" => "profesional",
                    "message" => "Inicio de sesión exitoso (profesional)",
                    "correo" => $user["correo"],
                    "nombre" => $user["Nombre"],
                    "apellido" => $user["Apellido"],
                    "especialidad" => $user["Especialidad"],
                    "telefono" => $user["Telefono"],
                    "direccion" => $user["Direccion"]
                ]);
            } else {
                echo json_encode(["success" => false, "message" => "Contraseña incorrecta"]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "Usuario no encontrado"]);
        }
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Correo y contraseña son requeridos"]);
}

$conn->close();
?>
