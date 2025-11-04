import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static Future<MySqlConnection> conectar() async {
    final settings = ConnectionSettings(
      host: 'localhost', 
      port: 3306, 
      user: 'root', 
      password: '', // Contraseña vacía por defecto
      db: 'doctime', 
    );

    return await MySqlConnection.connect(settings);
  }

  static Future<void> verificarConexion() async {
    final conn = await conectar();
    
    try {
      var results = await conn.query('SELECT 1');
      print('Conexión exitosa: $results');
    } catch (e) {
      print('Error en la conexión: $e');
    } finally {
      await conn.close();
    }
  }

  // Método para registrar un usuario
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
