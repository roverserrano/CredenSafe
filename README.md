# # CredenSafe - Gestor seguro de credenciales

CredenSafe es una aplicación para guardar y administrar credenciales personales de forma segura. Está pensada para usuarios que necesitan tener sus contraseñas, accesos y datos importantes organizados en un solo lugar, sin depender de notas sueltas, capturas de pantalla o documentos sin protección.

La aplicación funciona como una bóveda digital: el usuario crea una cuenta, configura una contraseña maestra y, a partir de ahí, puede guardar sus credenciales dentro de un espacio privado. La idea principal es que el acceso a la información sensible sea cómodo para el usuario, pero manteniendo una capa fuerte de protección.

## ¿Qué permite hacer?

Con CredenSafe el usuario puede:

- Crear una cuenta personal e iniciar sesión de forma segura.
- Crear una bóveda principal protegida con contraseña maestra.
- Guardar credenciales de aplicaciones, sitios web o servicios.
- Registrar datos como nombre de aplicación, correo, usuario, contraseña, teléfono, código de seguridad, notas privadas y datos de recuperación.
- Ver, editar y eliminar credenciales guardadas.
- Marcar credenciales como favoritas.
- Buscar credenciales por nombre de aplicación dentro de la bóveda.
- Generar contraseñas seguras desde un generador integrado.
- Copiar contraseñas al portapapeles con limpieza automática después de unos segundos.
- Activar desbloqueo con huella digital o reconocimiento biométrico, si el dispositivo lo permite.
- Bloquear la bóveda manualmente o de forma automática cuando la aplicación pasa a segundo plano.
- Revisar un historial de actividad de seguridad.

## Seguridad de la información

CredenSafe fue diseñada para que la información sensible no se guarde de forma directa y visible. Las contraseñas y datos privados se protegen antes de almacenarse, de modo que no queden expuestos como texto simple.

La contraseña maestra es clave para abrir la bóveda. Por seguridad, el usuario debe recordarla, ya que es la forma principal de proteger sus credenciales. Si se activa el desbloqueo biométrico, la aplicación permite abrir la bóveda con huella digital o autenticación del dispositivo, pero sin reemplazar la importancia de la contraseña maestra.

## Generador de contraseñas

La aplicación incluye un generador avanzado de contraseñas. El usuario puede crear contraseñas aleatorias, pronunciables o memorables, y ajustar opciones como longitud, números, símbolos, mayúsculas y minúsculas.

El generador muestra una indicación visual de qué tan fuerte es la contraseña generada, usando etiquetas fáciles de entender como "débil", "fuerte" o "muy fuerte". Además, mantiene un historial temporal de las últimas contraseñas generadas durante la sesión actual, sin guardarlas de forma permanente.

## Bóveda principal

La bóveda principal es el espacio donde se organizan las credenciales. Desde esa pantalla el usuario puede ver todas sus cuentas guardadas, buscar por nombre de aplicación, abrir detalles, crear nuevas credenciales o acceder al generador de contraseñas.

La búsqueda se realiza dentro de la aplicación, sobre las credenciales ya cargadas, para que el texto escrito por el usuario no tenga que enviarse a servicios externos.

## Desbloqueo biométrico

Si el dispositivo tiene huella digital o autenticación biométrica disponible, el usuario puede activar esta opción desde la configuración de seguridad. Para activarla, la aplicación solicita primero la contraseña maestra, como confirmación de identidad.

Una vez activada, el usuario puede desbloquear la bóveda con biometría. Si la autenticación biométrica falla o es cancelada, siempre se puede volver al desbloqueo con contraseña maestra.

## ¿Dónde se encuentra la aplicación para instalar?

El archivo de instalación para Android generado localmente se encuentra en:

```txt
credensafe/build/app/outputs/flutter-apk/app-debug.apk
```

Ese archivo puede usarse para pruebas en un dispositivo Android.

Cuando se genere una versión final para compartir con usuarios, la ubicación esperada del instalador será:

```txt
credensafe/build/app/outputs/flutter-apk/app-release.apk
```

Si el archivo final aún no aparece, primero se debe compilar la aplicación en modo release.

## Uso recomendado

CredenSafe está pensada para proteger información importante. Se recomienda:

- Usar una contraseña maestra larga y fácil de recordar.
- No compartir la contraseña maestra con otras personas.
- Activar el desbloqueo biométrico sólo en dispositivos personales.
- Mantener el dispositivo protegido con bloqueo de pantalla.
- Revisar periódicamente las credenciales guardadas.
- Cambiar contraseñas antiguas o repetidas.

## Estado del proyecto

CredenSafe se encuentra en desarrollo activo. Actualmente cuenta con autenticación de usuario, bóveda segura, gestión de credenciales, búsqueda local, generador avanzado de contraseñas, desbloqueo biométrico y registro de actividad de seguridad.

