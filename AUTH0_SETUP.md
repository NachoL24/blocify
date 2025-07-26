# Configuración de Auth0 para Blocify

## Credenciales configuradas

- **Domain**: `dev-5vezrqyf1x1t184t.us.auth0.com`
- **Client ID**: `rJCz1E9oK4BPwJE913XoYDw2rFyr16fh`
- **Client Secret**: `fvN39U6Y6lmmCkEpQpHoIZalnB20odL0toguN6kIr1xDwqxN0glwsAXpu2ITPbe-`

## URLs de Callback requeridas en Auth0 Dashboard

Para que la autenticación funcione correctamente, debes configurar las siguientes URLs en el Dashboard de Auth0:

### 1. Allowed Callback URLs
```
com.example.blocify://dev-5vezrqyf1x1t184t.us.auth0.com/android/com.example.blocify/callback,
com.example.blocify://dev-5vezrqyf1x1t184t.us.auth0.com/ios/com.example.blocify/callback
```

### 2. Allowed Logout URLs
```
com.example.blocify://dev-5vezrqyf1x1t184t.us.auth0.com/android/com.example.blocify/callback,
com.example.blocify://dev-5vezrqyf1x1t184t.us.auth0.com/ios/com.example.blocify/callback
```

### 3. Allowed Web Origins
```
file://
```

## Pasos para configurar en Auth0 Dashboard

1. Ve a [Auth0 Dashboard](https://manage.auth0.com/)
2. Navega a **Applications** → **Applications**
3. Selecciona tu aplicación
4. Ve a la pestaña **Settings**
5. Busca la sección **Application URIs**
6. Agrega las URLs mencionadas arriba en los campos correspondientes
7. Guarda los cambios

## Funcionalidades implementadas

- ✅ Autenticación con Auth0
- ✅ Gestión de credenciales
- ✅ Verificación de estado de autenticación
- ✅ Logout
- ✅ Navegación automática después del login
- ✅ Manejo de errores
- ✅ UI responsive con temas claro/oscuro

## Uso de la aplicación

1. Al abrir la app, aparece la pantalla de login
2. Pulsa "Iniciar Sesión con Auth0"
3. Se abre el navegador con la página de Auth0
4. Inicia sesión con tus credenciales
5. Serás redirigido automáticamente a la aplicación
6. En la pantalla principal, puedes cerrar sesión desde el menú de perfil

## Estructura de archivos

- `lib/config/auth0_config.dart` - Configuración de Auth0
- `lib/services/auth0_service.dart` - Servicio de autenticación
- `lib/screens/login_screen.dart` - Pantalla de inicio de sesión
- `lib/screens/home_screen.dart` - Pantalla principal
- `android/app/src/main/AndroidManifest.xml` - Configuración Android
- `ios/Runner/Info.plist` - Configuración iOS

## Notas importantes

- El esquema personalizado `com.example.blocify` debe coincidir con el Application ID
- Las URLs de callback deben estar exactamente configuradas en Auth0
- La aplicación verifica automáticamente si el usuario ya está autenticado al iniciar
