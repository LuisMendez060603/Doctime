import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  // Método para conectar con la base de datos
  static Future<MySqlConnection> conectar() async {
    final settings = ConnectionSettings(
      host: 'localhost', // O '127.0.0.1' si no funciona localhost
      port: 3306, // Puerto de MySQL (por defecto)
      user: 'root', // Usuario de XAMPP
      password: '', // Contraseña de XAMPP (vacía por defecto)
      db: 'doctime', // Nombre de tu base de datos
    );

    return await MySqlConnection.connect(settings);
  }

  // Método para registrar un usuario en la base de datos
  static Future<void> registrarUsuario(String nombre, String telefono, String correo, String password) async {
    final conn = await conectar();

    try {
      // Consulta SQL para insertar el nuevo usuario
      var result = await conn.query(
        'INSERT INTO PACIENTE (Nombre, Telefono, Correo, Historial_Citas) VALUES (?, ?, ?, ?)',
        [nombre, telefono, correo, ''], // Historial_Citas vacío por defecto
      );

      if (result.insertId != null) {
        print('Usuario registrado correctamente. ID de usuario: ${result.insertId}');
      } else {
        print('No se pudo insertar el usuario');
      }
    } catch (e) {
      print('Error al registrar el usuario: $e');
    } finally {
      await conn.close(); // Asegúrate de cerrar la conexión
    }
  }
}
