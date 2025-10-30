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

if (isset($data["nombre"]) && isset($data["apellido"]) && isset($data["telefono"]) && 
    isset($data["correo"]) && isset($data["password"]) && isset($data["role"])) {
    
    $nombre = $data["nombre"];
    $apellido = $data["apellido"];
    $telefono = $data["telefono"];
    $correo = $data["correo"];
    $password = password_hash($data["password"], PASSWORD_DEFAULT);
    $role = $data["role"];

    if ($role === "paciente") {
        // Registro de paciente
        $sql = "INSERT INTO paciente (Nombre, Apellido, Telefono, Correo, Password) 
                VALUES ('$nombre', '$apellido', '$telefono', '$correo', '$password')";
    } else if ($role === "profesional") {
        // Validar campos adicionales para profesional
        if (!isset($data["Especialidad"]) || !isset($data["Direccion"])) {
            echo json_encode(["success" => false, "message" => "Faltan datos del profesional"]);
            exit;
        }

        $especialidad = $data["Especialidad"];
        $direccion = $data["Direccion"];

        // Registro de profesional
        $sql = "INSERT INTO profesional (Nombre, Apellido, Especialidad, Telefono, Correo, Direccion, Password) 
                VALUES ('$nombre', '$apellido', '$especialidad', '$telefono', '$correo', '$direccion', '$password')";
    } else {
        echo json_encode(["success" => false, "message" => "Rol no válido"]);
        exit;
    }

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Registro exitoso"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Datos incompletos"]);
}

// Cerrar conexión
$conn->close();
?>
