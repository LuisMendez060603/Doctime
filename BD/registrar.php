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

if (isset($data["nombre"]) && isset($data["apellido"]) && isset($data["telefono"]) && isset($data["correo"]) && isset($data["password"])) {
    $nombre = $data["nombre"];
    $apellido = $data["apellido"]; // Capturar apellido
    $telefono = $data["telefono"];
    $correo = $data["correo"];
    $password = password_hash($data["password"], PASSWORD_DEFAULT); // Encriptar contraseña

    // Modificar la consulta SQL para incluir 'Apellido'
    $sql = "INSERT INTO paciente (Nombre, Apellido, Telefono, Correo, Password) 
            VALUES ('$nombre', '$apellido', '$telefono', '$correo', '$password')";

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
