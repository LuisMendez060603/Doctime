class AIResponseHandler {
  static String getResponse(String query) {
    query = query.toLowerCase().trim();

    // FUNCIONALIDAD DEL PROYECTO
    if (_containsAnyWord(query, ['proyecto', 'como funciona', 'qué hace', 'funciona'])) {
      return "🩺 **DocTime** es una app para agendar y gestionar citas médicas. Permite:\n"
          "• Pacientes pueden agendar, modificar y ver citas médicas\n"
          "• Profesionales gestionan pacientes y consultas\n"
          "• Sistema de verificación por correo electrónico\n"
          "• Historial médico y generación de PDFs de consultas";
    }

    // ESTRUCTURA DEL PROYECTO
    if (_containsAnyWord(query, ['archivos', 'estructura', 'carpetas', 'organización'])) {
      return "📂 **Estructura del proyecto:**\n"
          "• lib/paciente/: Funcionalidades para pacientes\n"
          "• lib/profesional/: Funcionalidades para médicos\n"
          "• lib/: Pantallas principales (login, registro, inicio)\n"
          "• BD/: Scripts y conexión a base de datos PHP/MySQL";
    }

    // TECNOLOGÍAS
    if (_containsAnyWord(query, ['tecnologia', 'framework', 'lenguaje', 'base de datos'])) {
      return "💻 **Detalles técnicos:**\n"
          "• Frontend: Flutter/Dart\n"
          "• Backend: PHP\n"
          "• Base de datos: MySQL\n"
          "• Generación de PDFs y persistencia local con SharedPreferences";
    }

    // FLUJO DE USO
    if (_containsAnyWord(query, ['flujo', 'proceso', 'pasos', 'funcionamiento'])) {
      return "⚙️ **Flujo principal de DocTime:**\n"
          "1. Registro y verificación por correo\n"
          "2. Login como paciente o profesional\n"
          "3. Agendar o gestionar citas\n"
          "4. Consultar historial médico\n"
          "5. Generar documentos en PDF";
    }

    // REGISTRO / VERIFICACIÓN
    if (_containsAnyWord(query, ['registro', 'registrar', 'crear cuenta', 'verificar', 'codigo', 'correo'])) {
      return "📧 **Registro y verificación:**\n"
          "• Regístrate en la pantalla *'Crear cuenta'* con tus datos.\n"
          "• Recibirás un código por correo; introdúcelo en *'Verificar correo'*.\n"
          "• Si no llega, usa *'Reenviar código'* o revisa spam.\n"
          "• Tu cuenta no se activa hasta verificar el correo.";
    }

    // LOGIN / SESIÓN
    if (_containsAnyWord(query, ['login', 'iniciar sesion', 'entrar', 'sesion'])) {
      return "🔐 **Inicio de sesión:**\n"
          "• Ingresa tu correo y contraseña en *'Iniciar sesión'*.\n"
          "• Si olvidaste la contraseña, usa *'Recuperar acceso'*.\n"
          "• Asegúrate de haber verificado tu cuenta antes.";
    }

    // AGENDAR CITA
    if (_containsAnyWord(query, ['agendar', 'agendar cita', 'reservar cita', 'nueva cita', 'programar cita'])) {
      return "🩵 **Cómo agendar una cita:**\n"
          "1. En el menú, selecciona *'Agendar cita'*.\n"
          "2. Escoge la fecha y hora disponibles.\n"
          "3. Confirma y recibirás una notificación.\n\n"
          "Puedes revisar tus citas en *'Mis Citas'*.";
    }

    // VER CONSULTA
    if (_containsAnyWord(query, ['ver consulta', 'consulta', 'detalles consulta', 'pdf consulta'])) {
      return "📋 **Cómo ver detalles de una consulta:**\n"
          "1. Ingresa a *'Historial de citas'*\n"
          "2. Selecciona la cita que deseas revisar\n"
          "3. Podrás ver los detalles de la consulta\n"
          "4. También puedes descargar el PDF de la consulta";
    }

    // MODIFICAR CITA
    if (_containsAnyWord(query, ['modificar cita', 'cambiar cita', 'editar cita', 'reprogramar cita'])) {
      return "🕒 **Cómo modificar o reprogramar una cita:**\n"
          "1. Ve a *'Mis Citas'*.\n"
          "2. Selecciona la cita que deseas cambiar.\n"
          "3. Pulsa *'Reprogramar'*.\n"
          "4. Elige una nueva fecha y hora disponibles.\n"
          "5. Guarda los cambios.\n\n"
          "El profesional recibirá la actualización automáticamente.";
    }

    // CANCELAR CITA
    if (_containsAnyWord(query, [
      'cancelar cita',
      'cancelar',
      'anular cita',
      'eliminar cita',
      'borrar cita'
    ])) {
      return "🚫 **Cómo cancelar una cita:**\n"
          "1. Abre *'Mis Citas'* desde el menú principal.\n"
          "2. Selecciona la cita que quieras cancelar.\n"
          "3. Presiona *'Cancelar cita'*.\n"
          "4. Confirma la cancelación.\n\n"
          "Recibirás un aviso de que la cita ha sido eliminada correctamente.";
    }

    // HISTORIAL
    if (_containsAnyWord(query, ['historial', 'consultas previas', 'citas pasadas'])) {
      return "📜 **Historial médico:**\n"
          "• Consulta citas anteriores y notas del médico.\n"
          "• Accede desde la sección *'Historial'*.\n"
          "• Puedes ver recomendaciones y diagnósticos registrados.";
    }

    // PERFIL
    if (_containsAnyWord(query, ['perfil', 'editar perfil', 'datos personales', 'direccion'])) {
      return "👤 **Perfil del usuario:**\n"
          "• Puedes editar nombre, teléfono, dirección y especialidad (si eres médico).\n"
          "• También puedes cambiar foto de perfil y preferencias de notificación.";
    }

    // REENVIAR CÓDIGO
    if (_containsAnyWord(query, ['reenviar codigo', 'reenviar código', 'reenviar'])) {
      return "📨 **Reenviar código de verificación:**\n"
          "• En la pantalla *'Verificar correo'*, toca *'Reenviar código'*.\n"
          "• Si no llega, revisa spam o confirma que el correo esté bien escrito.";
    }

    // TEMAS DE SALUD COMUNES
    if (_containsAnyWord(query, [
      'pastilla', 'medicamento', 'automedicar', 'recetar', 'tratamiento', 'sintoma', 
      'síntoma', 'me duele', 'dolor', 'mareo', 'tos', 'fiebre', 'diarrea'
    ])) {
      return "💊 **Consejo de salud:**\n"
          "No te automediques. DocTime no receta ni diagnostica.\n"
          "Te recomiendo **agendar una cita con un médico** para una evaluación profesional.\n"
          "Si tienes fiebre alta, dificultad para respirar o dolor fuerte, acude a urgencias.";
    }

    // EMERGENCIAS
    if (_containsAnyWord(query, ['emergencia', 'urgencia', 'grave', 'accidente'])) {
      return "🚨 **Emergencias médicas:**\n"
          "Si tu caso es grave, llama al número de emergencias o acude al hospital más cercano.\n"
          "DocTime no sustituye la atención médica presencial.";
    }

    // SOPORTE / PROBLEMAS
    if (_containsAnyWord(query, ['soporte', 'ayuda', 'problema', 'error', 'fallo', 'no puedo'])) {
      return "🛠️ **Soporte técnico:**\n"
          "• Si tienes un problema, entra en *'Ayuda'* dentro de la app.\n"
          "• Describe el error e incluye capturas si puedes.\n"
          "• También puedes contactar por correo al equipo de soporte.";
    }

    // --- BLOQUES AÑADIDOS (manteniendo todo lo anterior) ---
    // 1️⃣ RESPUESTAS INTELIGENTES Y PERSONALIZADAS
    if (_containsAnyWord(query, ['hola', 'buenas', 'saludo', 'hey', 'qué tal', 'buen día'])) {
      return "👋 ¡Hola! Soy DocBot, tu asistente médico virtual. ¿En qué puedo ayudarte hoy?";
    }

    if (_containsAnyWord(query, ['gracias', 'muchas gracias', 'te agradezco'])) {
      return "😊 ¡De nada! Cuídate mucho y recuerda mantener tus citas al día 💙";
    }

    if (_containsAnyWord(query, ['adios', 'hasta luego', 'nos vemos', 'bye'])) {
      return "👋 ¡Hasta pronto! No olvides agendar tu próxima cita si lo necesitas 🩵";
    }

    // 2️⃣ RECOMENDACIONES DE SALUD GENERALES
    if (_containsAnyWord(query, ['estres', 'ansiedad', 'depresion', 'triste', 'preocupado'])) {
      return "🧘 **Consejo emocional:**\n"
          "El estrés y la ansiedad son comunes. Intenta descansar bien, respirar profundo y hablar con alguien de confianza.\n"
          "Si sientes que te sobrepasa, agenda una cita con un psicólogo en DocTime 💙";
    }

    if (_containsAnyWord(query, ['alimentacion', 'comer', 'dieta', 'saludable', 'nutricion'])) {
      return "🥗 **Consejo de alimentación:**\n"
          "Lleva una dieta balanceada, evita exceso de azúcar y bebidas procesadas.\n"
          "DocTime cuenta con profesionales en nutrición si quieres un plan personalizado.";
    }

    if (_containsAnyWord(query, ['ejercicio', 'deporte', 'caminar', 'correr', 'gym', 'actividad física'])) {
      return "💪 **Ejercicio y bienestar:**\n"
          "Realizar al menos 30 minutos de actividad física diaria mejora tu salud física y mental.\n"
          "Recuerda consultar a tu médico antes de iniciar rutinas intensas.";
    }

    if (_containsAnyWord(query, ['sueño', 'dormir', 'insomnio', 'descanso'])) {
      return "😴 **Consejo sobre el sueño:**\n"
          "Procura dormir entre 7 y 8 horas al día. Evita pantallas antes de dormir y mantén un horario regular de descanso.";
    }

    if (_containsAnyWord(query, ['agua', 'hidratacion', 'beber'])) {
      return "💧 **Hidratación:**\n"
          "Beber suficiente agua (entre 1.5 y 2 litros al día) ayuda a mantener tu cuerpo en equilibrio y mejora la concentración.";
    }

    // 5️⃣ SÍNTOMAS ESPECÍFICOS (sin diagnosticar)
    if (_containsAnyWord(query, ['me duele la cabeza', 'dolor de cabeza', 'migraña'])) {
      return "🤕 **Dolor de cabeza:**\n"
          "Podría deberse a estrés, deshidratación o falta de sueño. Descansa, hidrátate y evita pantallas por un rato.\n"
          "Si el dolor persiste o es muy fuerte, agenda una cita con un médico en DocTime.";
    }

    if (_containsAnyWord(query, ['dolor estomago', 'nausea', 'vomito', 'diarrea'])) {
      return "🤢 **Molestia estomacal:**\n"
          "Evita comidas pesadas y mantente hidratado. Si el malestar continúa más de un día o hay fiebre, consulta con un profesional.";
    }

    if (_containsAnyWord(query, ['tos', 'gripa', 'gripe', 'resfriado', 'catarro'])) {
      return "🤧 **Síntomas de resfriado:**\n"
          "Descansa, mantente abrigado y toma líquidos. Si tienes fiebre o dificultad para respirar, acude a un médico.";
    }

    if (_containsAnyWord(query, ['fiebre', 'temperatura alta', 'escalofríos'])) {
      return "🌡️ **Fiebre:**\n"
          "Puede ser una respuesta del cuerpo ante una infección. Hidrátate bien y descansa.\n"
          "Si supera los 38.5°C o persiste, agenda una cita en DocTime.";
    }

    if (_containsAnyWord(query, ['dolor garganta', 'picazon garganta', 'amigdalas'])) {
      return "😷 **Dolor de garganta:**\n"
          "Bebe líquidos tibios y evita cambios bruscos de temperatura. Si notas dificultad al tragar o fiebre, consulta a un médico.";
    }

    // 6️⃣ CONVERSACIÓN GENERAL (modo asistente)
    if (_containsAnyWord(query, ['quien eres', 'que eres', 'tu nombre', 'como te llamas'])) {
      return "🤖 Soy **DocBot**, el asistente virtual de **DocTime**. Te ayudo a gestionar tus citas médicas y brindarte consejos básicos de salud 💙";
    }

    if (_containsAnyWord(query, ['que puedes hacer', 'que haces', 'en que ayudas', 'funcionas'])) {
      return "🩺 Puedo ayudarte con:\n"
          "• Agendar, modificar o cancelar citas\n"
          "• Consultar tu historial médico\n"
          "• Brindarte consejos generales de salud y bienestar";
    }

    if (_containsAnyWord(query, ['como agendo', 'agendar cita', 'hacer cita', 'nueva cita'])) {
      return "📅 Para agendar una cita, ve a la sección **Citas > Nueva cita**, selecciona el médico y la fecha disponible.\n"
          "También puedo ayudarte si me dices: *“Agendar cita con el doctor López el viernes”*.";
    }

    // RESPUESTA POR DEFECTO (sigue existiendo)
    return "🤖 Puedo ayudarte con:\n"
        "• Agendar, modificar o cancelar citas\n"
        "• Registro, verificación y perfil\n"
        "• Historial médico y soporte técnico\n"
        "• Consejos generales de salud\n\n"
        "💡 Intenta preguntarme por ejemplo: *“Cómo reprogramo una cita”* o *“Me duele la cabeza, qué hago”*";
  }

  // Método auxiliar
  static bool _containsAnyWord(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }
}
