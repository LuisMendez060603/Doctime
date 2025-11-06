class AIResponseHandler {
  static String getResponse(String query) {
    query = query.toLowerCase();

    if (_containsAnyWord(query, ['hola', 'buenos dias', 'buenas tardes', 'hey'])) {
      return "¡Hola! Soy el asistente virtual de DocTime. Puedo ayudarte con información sobre la app y temas médicos generales. No doy diagnósticos ni receto medicamentos.";
    }

    // Registro / Verificación
    if (_containsAnyWord(query, ['registro', 'registrar', 'crear cuenta', 'verificar', 'codigo', 'correo'])) {
      return "Registro y verificación:\n"
        "• Regístrate desde la pantalla 'Registrarse' con tus datos.\n"
        "• Recibirás un código por correo; debes introducirlo en 'Verificar correo' para activar tu cuenta.\n"
        "• Si no llega, usa 'Reenviar código'.\n"
        "• La cuenta no se activa hasta que verifiques con el código.";
    }

    // Inicio de sesión / sesión
    if (_containsAnyWord(query, ['login', 'iniciar sesion', 'entrar', 'sesion'])) {
      return "Inicio de sesión:\n"
        "• Ve a 'Iniciar sesión', introduce tu correo y contraseña.\n"
        "• Si olvidaste la contraseña, usa la opción de recuperar (si está disponible).\n"
        "• Asegúrate de haber verificado tu correo antes de iniciar sesión.";
    }

    // Agendar / reservar citas
    if (_containsAnyWord(query, ['cita', 'agendar', 'reservar', 'horario', 'agenda'])) {
      return "Cómo agendar una cita:\n"
        "1. Selecciona 'Agendar cita' o la especialidad que necesitas.\n"
        "2. Elige un profesional y un horario disponible.\n"
        "3. Confirma la cita y la encontrarás en tu agenda.\n"
        "Para cancelar o reprogramar, usa la pantalla de detalles de la cita.";
    }

    // Historial
    if (_containsAnyWord(query, ['historial', 'citas pasadas', 'consultas previas'])) {
      return "Historial de citas:\n"
        "• En 'Historial de Citas' verás consultas anteriores, notas y recomendaciones del profesional.\n"
        "• Puedes abrir cada registro para ver detalles.";
    }

    // Perfil y configuración
    if (_containsAnyWord(query, ['perfil', 'editar perfil', 'datos personales', 'direccion'])) {
      return "Perfil y configuración:\n"
        "• Desde tu perfil puedes actualizar nombre, teléfono, dirección y (si eres profesional) especialidad.\n"
        "• Cambia tu foto y preferencias desde la pantalla de perfil.";
    }

    // Reenvío código
    if (_containsAnyWord(query, ['reenviar', 'reenviar codigo', 'reenviar código'])) {
      return "Reenviar código:\n"
        "• En la pantalla de verificación pulsa 'Reenviar código' para recibir un nuevo código al correo registrado.\n"
        "• Si no llega, revisa la carpeta de spam y verifica que el correo sea correcto.";
    }

    // Cancelaciones / pagos / calificaciones
    if (_containsAnyWord(query, ['cancelar', 'cancelacion', 'pago', 'pagar', 'calificar', 'reseña'])) {
      return "Cancelaciones y pagos:\n"
        "• Cancela o reprograma desde el detalle de la cita. Los pagos (si aplica) se gestionan en la pantalla de pago.\n"
        "• Puedes calificar al profesional después de la consulta desde el historial o detalle de la cita.";
    }

    // Emergencias y autocuidado
    if (_containsAnyWord(query, ['emergencia', 'urgencia', 'grave'])) {
      return "⚠️ Emergencias: si es una emergencia médica contacta a los servicios de emergencia o acude al centro médico más cercano. No esperes una consulta en línea.";
    }

    if (_containsAnyWord(query, ['medicina', 'pastilla', 'medicamento', 'automedicar', 'recetar'])) {
      return "No automediques:\n"
        "• No doy recomendaciones sobre medicamentos. Solo un profesional tras evaluación puede recetar.\n"
        "• Si tienes dudas sobre un medicamento, agenda una cita con un profesional.";
    }

    // Soporte y contacto
    if (_containsAnyWord(query, ['soporte', 'ayuda', 'contacto', 'problema', 'error'])) {
      return "Soporte:\n"
        "• Para problemas con la app o el correo, contacta soporte desde la sección 'Ayuda' o envía un correo al equipo técnico.\n"
        "• Incluye capturas y descripción del problema para acelerar la ayuda.";
    }

    // Respuesta por defecto
    return "Puedo ayudarte con:\n"
      "• Registro, verificación y reenvío de código\n"
      "• Agendar, cancelar o ver citas\n"
      "• Consultar historial y editar perfil\n\n"
      "Recuerda: no doy diagnósticos ni receto medicamentos. En caso de duda médica o emergencia, consulta a un profesional.";
  }

  static bool _containsAnyWord(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }
}