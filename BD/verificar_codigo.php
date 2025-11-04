<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "doctime";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["estado" => "error", "mensaje" => "Conexión fallida: " . $conn->connect_error]));
}

// Leer datos enviados desde Flutter
$data = json_decode(file_get_contents("php://input"), true);

$correo = $data['correo'] ?? '';
$codigo = $data['codigo'] ?? '';

if ($correo && $codigo) {

    // Primero buscar en paciente
    $sql = "SELECT * FROM paciente WHERE Correo='$correo' AND Codigo_Verificacion='$codigo'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $conn->query("UPDATE paciente SET Verificado=1 WHERE Correo='$correo'");
        echo json_encode(["estado" => "ok", "mensaje" => "Registro exitoso"]);
    } else {
        // Si no se encuentra en paciente, buscar en profesional
        $sql2 = "SELECT * FROM profesional WHERE Correo='$correo' AND Codigo_Verificacion='$codigo'";
        $result2 = $conn->query($sql2);

        if ($result2->num_rows > 0) {
            $conn->query("UPDATE profesional SET Verificado=1 WHERE Correo='$correo'");
            echo json_encode(["estado" => "ok", "mensaje" => "Registro exitoso"]);
        } else {
            echo json_encode(["estado" => "error", "mensaje" => "Código incorrecto"]);
        }
    }

} else {
    echo json_encode(["estado" => "error", "mensaje" => "Faltan datos"]);
}

$conn->close();
?>
